import os
import subprocess
import sys
from colorama import init, Fore, Style

init(autoreset=True)


def print_script(message):
    print(f"{Fore.CYAN}{Style.BRIGHT}[SCRIPT] {message}{Style.RESET_ALL}")


def print_error(message):
    print(f"{Fore.RED}{Style.BRIGHT}[ERROR] {message}{Style.RESET_ALL}")


def build_odin_project(debug=True):
    print_script(f"Building Odin project in {'debug' if debug else 'release'} mode...")

    os.makedirs("bin", exist_ok=True)

    if sys.platform.startswith("win"):
        output_file = "bin\\rl.exe"
    else:
        output_file = "bin/rl"

    build_cmd = ["odin", "build", "src", f"-out:{output_file}"]

    if debug:
        build_cmd.extend(["-debug"])
    else:
        build_cmd.extend(["-o:speed", "-no-bounds-check", "-disable-assert"])

    print(f"{Fore.GREEN}{Style.BRIGHT}--- Odin Timings ---{Style.RESET_ALL}")

    build_cmd.extend(["-show-timings"])

    result = subprocess.run(build_cmd, check=True)
    if result.returncode != 0:
        print_error(f"Odin build failed with exit code {result.returncode}")
        sys.exit(1)

    print(f"{Fore.GREEN}{Style.BRIGHT}--- Odin Timings End ---{Style.RESET_ALL}")
    print_script(
        f"Odin build completed successfully. Binary saved as {output_file}")

    return output_file


def run_binary(binary_path, game_name=None):
    print_script(f"Running {binary_path}...")
    print(f"{Fore.GREEN}{Style.BRIGHT}--- Program Output Begin ---{Style.RESET_ALL}")

    try:
        cmd = [binary_path]
        if game_name:
            cmd.append(game_name)

        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print_error(f"Binary execution failed with exit code {e.returncode}")
    except Exception as e:
        print_error(f"An error occurred while running the binary: {e}")

    print(f"{Fore.GREEN}{Style.BRIGHT}--- Program Output End ---{Style.RESET_ALL}")


def main():
    os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    print_script("Build process started")

    debug_mode = True
    game_name = None

    for arg in sys.argv[1:]:
        if arg == "--debug":
            debug_mode = True
        elif arg == "--release":
            debug_mode = False
        elif not arg.startswith("--"):
            game_name = arg

    if debug_mode is None:
        print_error("Please specify either --debug or --release")
        sys.exit(1)

    binary_path = build_odin_project(debug=debug_mode)
    run_binary(binary_path, game_name)
    print_script("Build process and execution completed")


if __name__ == "__main__":
    main()
