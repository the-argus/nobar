import i3ipc
import subprocess

# store all the windows as window_title: container_id pairs
def collect_all_windows(
    tree_node: i3ipc.con.Con,
    collection: dict,
    visited_containers: set,
    key=(lambda x: x.id),
    value=(lambda x: x.window_title),
):
    if not tree_node.id in visited_containers and tree_node.window_title != None:
        collection[key(tree_node)] = value(tree_node)
        visited_containers.add(tree_node.id)

    for child in tree_node.descendants():
        collect_all_windows(child, collection, visited_containers)


# function to open an interactive rofi chooser and then return its output
def rofi_choose_between(options: list, exit_on_fail=True, string_conversion=None):
    if string_conversion is not None:
        map(string_conversion, options)
    stdin = "\n".join(options)
    rofi = subprocess.Popen(
        ["rofi", "-dmenu", "-matching", "fuzzy"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    chosen_window, _ = rofi.communicate(input=stdin.encode("utf8"), timeout=None)
    chosen_window = chosen_window.decode("utf8")

    if exit_on_fail and chosen_window == "":
        print("No rofi selection made, exiting quietly.")
        exit(0)

    return chosen_window


def rofi_choose_between_dict_by_value(options: dict, **rofi_kwargs):
    # init dictionary which is going to be a value:key version of options
    inverted_options = {}
    # account for the string conversion function if necessary
    string_conversion = rofi_kwargs.get("string_conversion", None)

    if string_conversion is not None:
        for key, value in options.items():
            inverted_options[string_conversion(value)] = key
    else:
        for key, value in options.items():
            inverted_options[value] = key

    choice = rofi_choose_between(options.values(), **rofi_kwargs)

    return inverted_options[choice]


def rofi_choose_between_dict(options: dict, **rofi_kwargs):
    choice = rofi_choose_between(options.keys(), **rofi_kwargs)
    return options[choice]
