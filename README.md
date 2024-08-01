# rl

A project which aims to provide a collection of Raylib games written in Odin. It currently includes the following games:
- Pong: Classic paddle game where two players compete to score points by hitting a ball back and forth.

Game previews are available in [images](images/images.md).

## Prerequisites

To build and run this project, you need:

- [Odin Compiler](https://odin-lang.org/)
- [Raylib](https://www.raylib.com/)
- Python 3.x (for build script)

Ensure that both Odin and Raylib are properly installed and their paths are set in your system's environment variables.

## Project Structure

```sh
├── src/            # Odin source files
├── images/         # Game previews
├── scripts/        # Build script
│   └── build.py
└── bin/            # Output directory for compiled binary
```

## Building and Running

1. Clone the repository with submodules:

```sh
git clone https://github.com/dmcg310/rl.git
cd rl
```

2. Install the required Python package:

```sh
pip install colorama ply
```

3. Build the project:

```sh
python3 scripts/build.py --debug <game>
```

Or

```sh
python3 scripts/build.py --release <game>
```

Where `<game>` is replaced with the game you want to run, e.g. `pong`.

This script will build the Odin project in the specified mode (debug or release), and run the resulting binary with the game specified.

## References

- [The Odin Programming Language](https://odin-lang.org/)
- [Raylib](https://www.raylib.com/)
