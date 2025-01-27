from pathlib import Path
from sys import argv

p  = Path("~/Pictures/BG").expanduser().absolute()

def list():
    if p.exists():
        images = ", ".join(f'"{p.as_posix()}/{im.name}"' for im in p.iterdir())
    else:
        images = ""
    result = "return {" + images + "};"
    with open("backgrounds.lua", "w") as f:
        f.write(result)


def download():
    p.mkdir(parents=True, exist_ok=True)
    # unimplemented

    
def main():
    if len(argv) == 1:
        download()
        list()
        return
    arg = argv[1]
    if arg == "list":
        list()
    elif arg in {"down", "download"}:
        download()

if __name__ == "__main__":
    main()
