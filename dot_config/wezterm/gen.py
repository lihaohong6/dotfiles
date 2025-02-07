from pathlib import Path
import subprocess
from sys import argv
from itertools import chain

import socket

p = Path("~/Pictures/BG").expanduser().absolute()

def list_files():
    if p.exists():
        dirs = ["public"]
        if socket.gethostname().lower() == "oreki":
            dirs.append("private")
            print("On home computer")
        else:
            print("Not on home computer")
        files = list(chain(*[(p / dir).iterdir() for dir in dirs]))
        
        print(f"Found {len(files)} files")
        images = ", ".join(f'"{im.absolute().as_posix()}"' for im in files)
    else:
        print("No BG files found")
        images = ""
    result = "return {" + images + "};"
    with open("backgrounds.lua", "w") as f:
        f.write(result)


def download():
    if not p.exists():
        print("Cloning image repo from gh")
        subprocess.run(["gh", "repo", "clone", "BG"], 
                       cwd=p.parent,
                       check=True)
    else:
        print("Updating images from gh")
        subprocess.run(["git", "pull"],
                       cwd=p,
                       check=True)

    
def main():
    if len(argv) == 1:
        download()
        list_files()
        return
    arg = argv[1]
    if arg == "list":
        list_files()
    elif arg in {"down", "download"}:
        download()

if __name__ == "__main__":
    main()
