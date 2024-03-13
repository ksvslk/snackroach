extends VBoxContainer

var payment = null
var ios_payment = null

const ALL_IN_PACK = "all_in_pack"
const UNLIMITED_TAPS = "unlimited_taps"
const UNLOCK_ALL_LEVELS = "unlock_all_levels"
const RESTORE = "restore"

var SKUS = [
	ALL_IN_PACK,
	UNLIMITED_TAPS,
	UNLOCK_ALL_LEVELS
]


var loading_animation := load("res://styles/AnimatedLoadingTexture.tres") as AnimatedTexture

onready var restore = $Restore
onready var all_in_pack = $AllInPack
onready var unlock_all_levels = $UnlockAllLevels
onready var unlimited_taps = $UnlimitedTaps
onready var super = $Super
onready var store_timer = $StoreTimer


func _ready():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		payment = Engine.get_singleton("GodotGooglePlayBilling")
		# No params.
		payment.connect("connected", self, "_on_connected")
		# No params.
		payment.connect("disconnected", self, "_on_disconnected")
		# Response ID (int), Debug message (string).
		payment.connect("connect_error", self, "_on_connect_error")
		# Purchases (Dictionary[]).
		payment.connect("purchases_updated", self, "_on_purchases_updated")
		# Response ID (int), Debug message (string).
		payment.connect("purchase_error", self, "_on_purchase_error")
		# SKUs (Dictionary[]).
		payment.connect("sku_details_query_completed", self, "_on_sku_details_query_completed")
		# Response ID (int), Debug message (string), Queried SKUs (string[]).
		payment.connect("sku_details_query_error", self, "_on_sku_details_query_error")
		# Purchase token (string).
		payment.connect("purchase_acknowledged", self, "_on_purchase_acknowledged")
		# Response ID (int), Debug message (string), Purchase token (string).
		payment.connect("purchase_acknowledgement_error", self, "_on_purchase_acknowledgement_error")
		# Purchase token (string).
		payment.connect("purchase_consumed", self, "_on_purchase_consumed")
		# Response ID (int), Debug message (string), Purchase token (string).
		payment.connect("purchase_consumption_error", self, "_on_purchase_consumption_error")
		# Purchases (Dictionary[])
		payment.connect("query_purchases_response", self, "_on_query_purchases_response")
		payment.startConnection()
		restore.visible = false
	elif Engine.has_singleton("InAppStore"):
		ios_payment = Engine.get_singleton("InAppStore")
		store_timer.connect("timeout", self, "handle_ios_store_events")
		store_timer.start()
		request_ios_products_info()
		restore.disabled = false
	else:
		printerr("Android IAP support is not enabled. Make sure you have enabled 'Custom Build' and installed and enabled the GodotGooglePlayBilling plugin in your Android export settings! This application will not work.")


func request_ios_products_info():
	ios_payment.request_product_info({ "product_ids": SKUS })


func handle_ios_store_events():
	while ios_payment.get_pending_event_count() > 0:
		var response_event = ios_payment.pop_pending_event()
		if response_event["type"] == "purchase":
			var result = response_event["result"]
			if result == "ok":
				_give_content(response_event["product_id"])
				set_active_for_bonus_menu(response_event["product_id"])
			elif result == "progress":
				set_loading_for_bonus_menu(response_event["product_id"])
			else:
				set_active_for_bonus_menu(response_event["product_id"])
		elif response_event["type"] == "product_info":
			if response_event["result"] == "ok":
				update_ios_products_buttons(response_event)
			else:
				printerr("Could not fetch products info.")
		elif response_event["type"] == "restore":
			if response_event["result"] == "ok":
				_give_content(response_event["product_id"])
			elif response_event["result"] == "error":
				printerr("Restore error.")
			elif response_event["result"] == "completed":
				printerr("Restore completed")
			else:
				printerr("No restore.")
			set_active_for_bonus_menu(RESTORE)


func set_loading_for_bonus_menu(product_id: String):
	all_in_pack.disabled = true
	unlock_all_levels.disabled = true
	unlimited_taps.disabled = true
	restore.disabled = true
	if product_id == ALL_IN_PACK:
		all_in_pack.icon = loading_animation
	elif product_id == UNLOCK_ALL_LEVELS:
		unlock_all_levels.icon = loading_animation
	elif product_id == UNLIMITED_TAPS:
		unlimited_taps.icon = loading_animation
	elif product_id == RESTORE:
		restore.icon = loading_animation


func set_active_for_bonus_menu(product_id: String):
	restore.disabled = false
	all_in_pack.disabled = false
	unlock_all_levels.disabled = false
	unlimited_taps.disabled = false
	if product_id:
		if product_id == ALL_IN_PACK:
			all_in_pack.icon = all_in_pack.regular_icon
		elif product_id == UNLOCK_ALL_LEVELS:
			unlock_all_levels.icon = unlock_all_levels.regular_icon
		elif product_id == UNLIMITED_TAPS:
			unlimited_taps.icon = unlimited_taps.regular_icon
		elif product_id == RESTORE:
			restore.icon = null


func update_ios_products_buttons(response_event):
	for index in range(response_event.ids.size()):
		var product_id = response_event.ids[index]
		print("response event: ", response_event)
		var title = response_event["titles"][index]
		var price = response_event["localized_prices"][index]
		if product_id == UNLOCK_ALL_LEVELS:
			unlock_all_levels.text = title.to_upper() + " - " + price
			unlock_all_levels.disabled = false
		elif product_id == UNLIMITED_TAPS:
			unlimited_taps.text = title.to_upper() + " - " + price
			unlimited_taps.disabled = false
	_display_purchase_buttons_reasonably()


func _on_connected():
	if !C.is_amazon:
		#print("PurchaseManager connected")
		payment.queryPurchases("inapp") # Use "subs" for subscriptions.
		payment.querySkuDetails(SKUS, "inapp")


func _notification(what):
	if what == NOTIFICATION_APP_RESUMED && !C.is_amazon:
		payment.queryPurchases("inapp")


func _on_query_purchases_response(query_result):
	#print("_on_query_purchases_response", query_result)
	if query_result.status == OK:
		for purchase in query_result.purchases:
			# We must acknowledge all purchases.
			# See https://developer.android.com/google/play/billing/integrate#process for more information
			#print("_handle_purchase", purchase)
			_handle_purchase(purchase)
	else:
		printerr("queryPurchases failed, response code: ",
				query_result.response_code,
				" debug message: ", query_result.debug_message)

# "description":"One permanent ball you can use in all levels",
# "id":"ball",
# "one_time_purchase_details":{"formatted_price":"€1.99","price_amount_micros":1990000,"price_currency_code":"EUR"},
# "title":"Ball (com.indest.penalty2d (unreviewed))",
# "type":"inapp"
func _on_sku_details_query_completed(sku_details):
	##print("_on_sku_details_query_completed", sku_details)
	for available_sku in sku_details:
		var price = available_sku["price"]
		if available_sku["sku"] == ALL_IN_PACK:
			all_in_pack.text = (available_sku["title"].get_slice("(", 0) + " - " + price).to_upper()
			all_in_pack.disabled = false
		elif available_sku["sku"] == UNLOCK_ALL_LEVELS:
			unlock_all_levels.text = (available_sku["title"].get_slice("(", 0) + " - " + price).to_upper()
			unlock_all_levels.disabled = false
		elif available_sku["sku"] == UNLIMITED_TAPS:
			unlimited_taps.text = (available_sku["title"].get_slice("(", 0) + " - " + price).to_upper()
			unlimited_taps.disabled = false
	_display_purchase_buttons_reasonably()


#{"is_acknowledged":false,
#"is_auto_renewing":false,
#"order_id":"GPA.3319-2871-9696-71923",
#"original_json":"{\"orderId\":\"GPA.3319-2871-9696-71923\",
#\"packageName\":\"com.indest.penalty2d\",
#\"productId\":\"ball\",
#\"purchaseTime\":1669751718344,
#\"purchaseState\":0,
#\"purchaseToken\":\"gafkpajggancdhjaifahkhgj.AO-J1OzNbuv8fDgsV2u98PvuAIwF8gOOZ45p0iyNvvd-wJ16xju0XG73KbWQsqv1ajl1qGi5jl3SSfiXH1nyimwjHQyn6nGKYQ\",
#\"quantity\":1,
#\"acknowledged\":false}",
#"package_name":"com.indest.penalty2d",
#"products":["ball"],
#"purchase_state":1,
#"purchase_time":1669751718344,
#"purchase_token":"REMOVED",
#"quantity":1,
#"signature":"REMOVED

func _handle_purchase(purchase):
	if purchase.purchase_state == 1:
		if !purchase.is_acknowledged:
			_give_content(purchase.sku)
			payment.acknowledgePurchase(purchase.purchase_token)
			#print("Purchase " + str(purchase.sku) + " has not been acknowledged. Acknowledging...")
		else:
			#print("Purchase " + str(purchase.sku) + " was acknowledged already. Giving content if needed.")
			_give_content(purchase.sku)


func _give_content(sku):
	match sku:
		ALL_IN_PACK:
			Data.set_all_in_pack_state(1)
			_display_purchase_buttons_reasonably()
			Data.emit_signal("all_in_pack")
		UNLIMITED_TAPS:
			Data.set_unlimited_taps_state(1)
			_display_purchase_buttons_reasonably()
			Data.emit_signal("unlimited_taps")
		UNLOCK_ALL_LEVELS:
			Data.set_unlock_all_levels_state(1)
			_display_purchase_buttons_reasonably()
			Data.emit_signal("unlock_all_levels")
	if ios_payment:
		ios_payment.finish_transaction(sku)


func _on_purchases_updated(purchases):
	#print("Purchases updated (on resume and startup): %s" % to_json(purchases))
	# See _on_connected
	for purchase in purchases:
		_handle_purchase(purchase)


func _on_purchase_acknowledged(purchase_token):
	pass
	#print("Purchase acknowledged: %s" % purchase_token)
	

func _on_purchase_consumed(purchase_token):
	pass
	#print("Purchase consumed successfully: %s" % purchase_token)
	
	
func _on_purchase_error(code, message):
	printerr("Purchase error %d: %s" % [code, message])
	

func _on_purchase_acknowledgement_error(code, message, token):
	printerr("Purchase acknowledgement error %d: %s %s" % [code, message, token])
	
	
func _on_purchase_consumption_error(code, message, purchase_token):
	printerr("Purchase consumption error %d: %s, purchase token: %s" % [code, message, purchase_token])


func _on_sku_details_query_error(code, message, list):
	printerr("SKU details query error %d: %s %s" % [code, message, to_json(list)])
	

func _on_disconnected():
	#print("GodotGooglePlayBilling disconnected. Will try to reconnect in 10s...")
	yield(get_tree().create_timer(10), "timeout")
	payment.startConnection()


func _purchase(sku):
	if payment:
		var response = payment.purchase(sku)
		if response.status != OK:
			printerr("Purchase error %s: %s" % [response.response_code, response.debug_message])
	elif ios_payment:
		var result = ios_payment.purchase({ "product_id": sku })
		if result == OK:
			set_loading_for_bonus_menu(sku)
		else:
			pass
			#show_error()

# UI
func _on_AllInPack_pressed():
	if payment:
		 get_parent()._on_BackButton_pressed()
	_purchase(ALL_IN_PACK)


func _on_UnlockAllLevels_pressed():
	if payment:
		get_parent()._on_BackButton_pressed()
	_purchase(UNLOCK_ALL_LEVELS)


func _on_UnlimitedTaps_pressed():
	if payment:
		get_parent()._on_BackButton_pressed()
	_purchase(UNLIMITED_TAPS)
	
	
func _display_purchase_buttons_reasonably():
	if OS.get_name() == "Android":
		if Data.get_unlimited_taps_state() == 1:
			unlimited_taps.visible = false
			all_in_pack.visible = false
		if Data.get_unlock_all_levels_state() == 1:
			unlock_all_levels.visible = false
			all_in_pack.visible = false
		if not unlimited_taps.visible and not unlock_all_levels.visible and not all_in_pack.visible:
			super.visible = true
			restore.visible = false
	elif OS.get_name() == "iOS":
		var taps_purchased = Data.get_unlimited_taps_state() == 1
		var skip_purchased = Data.get_unlock_all_levels_state() == 1
		if taps_purchased:
			unlimited_taps.visible = false
		if skip_purchased:
			unlock_all_levels.visible = false
		if taps_purchased && skip_purchased:
			super.visible = true
			restore.visible = false
		all_in_pack.visible = false


func _set(property, value):
	if property == "visible":
		if value == true:
			_display_purchase_buttons_reasonably()
		else:
			unlock_all_levels.remove_rainbow_effect()
			unlimited_taps.remove_rainbow_effect()


func _on_Restore_pressed():
	if ios_payment:
		set_loading_for_bonus_menu(RESTORE)
		var _result = ios_payment.restore_purchases()
