import os
path = "/Users/ksvslk/Projects/operation-aidos/levels"
# ACHTUNG! Move levels only from TOP to BOTTOM. Won't work the other way.
level_nr_to_move = 14
where_to_move = 32

if level_nr_to_move > where_to_move:
    os.rename(f"{level_nr_to_move}.tscn",f"temp.tscn")
    for level in reversed(range(where_to_move, level_nr_to_move)):
        os.rename(f"{level}.tscn", f"{level+1}.tscn")
    os.rename(f"temp.tscn",f"{where_to_move}.tscn")
elif level_nr_to_move < where_to_move:
    os.rename(f"{level_nr_to_move}.tscn",f"temp.tscn")
    for level in range(level_nr_to_move + 1, where_to_move + 1):
        os.rename(f"{level}.tscn", f"{level-1}.tscn")
    os.rename(f"temp.tscn",f"{where_to_move}.tscn")
