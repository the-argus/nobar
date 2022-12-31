import i3ipc
import subprocess

# store all the windows as window_title: container_id pairs
def collect_all_windows(tree_node: i3ipc.con.Con, collection: dict, visited_containers: set):
    if not tree_node.id in visited_containers and tree_node.window_title != None:
        collection[tree_node.window_title.lower()] = tree_node.id
        visited_containers.add(tree_node.id)

    for child in tree_node.descendants():
        collect_all_windows(child, collection, visited_containers)

# function to open an interactive rofi chooser and then return its output
def rofi_choose_between(options: list):
    stdin = "\n".join(options)
    rofi = subprocess.Popen(
        ["rofi", "-dmenu", "-matching", "fuzzy"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    chosen_window, _ = rofi.communicate(
        input=stdin.encode("utf8"), timeout=None
    )
    return chosen_window.decode("utf8")
