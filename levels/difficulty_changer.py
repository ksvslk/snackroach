import in_place

pars = [2,3,4,3,3,4,2,7,3,2,4,5,3,6,5,6,4,15,4,6,3,6,4,2,6,12,3,6,2,3,11,3,3,5,7,5,4,4,5,2,4,5,14,7,17,4,5,28,5,9,3,3,5,22,4,6,8,8,3,9,7,12,11,19,14,17,38,42,34]
max_taps = [4,5,6,5,5,6,4,9,5,4,6,7,5,8,7,8,6,17,6,8,5,8,6,4,8,14,5,8,4,5,13,5,5,7,9,7,6,6,7,4,6,7,16,9,19,6,7,30,7,11,5,5,7,24,6,8,10,10,5,11,9,14,13,21,16,19,40,44,36]
rewards = [2,2,2,2,2,2,2,4,2,2,2,3,2,3,3,3,2,8,2,3,2,3,2,2,3,6,2,3,2,2,6,2,2,3,4,3,2,2,3,2,2,3,7,4,9,2,3,14,3,5,2,2,3,11,2,3,4,4,2,5,4,6,6,10,7,9,19,21,17]

print(len(pars))
assert len(pars) == len(max_taps) == len(rewards) == 69

for i in range(1, 70): # 1 to 69
    with in_place.InPlace(str(i) + '.tscn') as file:
        for line in file:
            if "par = " in line:
                line = "par = " + str(pars[i-1]) + "\n"
            elif "max_taps = " in line:
                line = "max_taps = " + str(max_taps[i-1]) + "\n"
            elif "rewarded_taps_amount = " in line:
                line = "rewarded_taps_amount = " + str(rewards[i-1]) + "\n"
            file.write(line)
 