import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parent
PROJECTS = ("counter", "fsm_traffic", "fifo", "uart_tx")


def main():
    failed = False

    for project in PROJECTS:
        print(f"== {project} ==")
        project_dir = ROOT / project

        with tempfile.TemporaryDirectory(prefix=f"verilog-{project}-") as temp_dir:
            sim_path = Path(temp_dir) / "sim"
            compile_result = subprocess.run(
                [
                    "iverilog",
                    "-g2012",
                    "-o",
                    str(sim_path),
                    str(project_dir / "design.v"),
                    str(project_dir / "tb.v"),
                ],
                cwd=temp_dir,
                capture_output=True,
                text=True,
            )
            if compile_result.stdout:
                print(compile_result.stdout, end="")
            if compile_result.stderr:
                print(compile_result.stderr, end="", file=sys.stderr)
            if compile_result.returncode != 0:
                print(f"Result: compile failed for {project}")
                failed = True
                continue

            sim_result = subprocess.run(
                ["vvp", str(sim_path)],
                cwd=temp_dir,
                capture_output=True,
                text=True,
            )
            output = sim_result.stdout + sim_result.stderr
            print(output, end="")
            if (
                sim_result.returncode != 0
                or "FAIL" in output
                or "PASS" not in output
            ):
                print(f"Result: simulation failed for {project}")
                failed = True
            else:
                print(f"Result: PASS ({project})")

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
