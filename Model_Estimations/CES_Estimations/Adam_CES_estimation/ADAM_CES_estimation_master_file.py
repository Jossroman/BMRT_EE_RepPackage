# -*- coding: utf-8 -*-
"""
Created on Sat May  2 09:07:45 2026

@author: adity
"""

import subprocess
import sys
from pathlib import Path

base_dir = Path(__file__).resolve().parent

script_paths = [
    base_dir / "First Layer" / "ces_first_layer_bootstrap_code.py",
    base_dir / "First Layer" / "ces_first_layer_bootstrap_code_fixed.py",
    base_dir / "First Layer" / "ces_first_layer_ene_prod.py",
    base_dir / "First Layer" / "ces_first_layer_ene_prod_fixed.py",
    base_dir / "First Layer" / "ces_first_layer_rolling_est.py",
    base_dir / "Second Layer" / "nne_nat_cap_second_layer_upsilon.py",
    base_dir / "Second Layer" / "nne_nat_cap_second_layer.py",
    base_dir / "Third Layer" / "nne_nat_cap_third_layer_upsilon.py",
    base_dir / "Third Layer" / "nne_nat_cap_third_layer.py"
]

for script_path in script_paths:
    print("\n" + "=" * 80)
    print(f"Running: {script_path}")
    print("=" * 80 + "\n")

    process = subprocess.Popen(
        [sys.executable, "-u", str(script_path)],
        cwd=script_path.parent,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1
    )

    for line in process.stdout:
        print(line, end="", flush=True)

    return_code = process.wait()

    if return_code != 0:
        raise subprocess.CalledProcessError(return_code, process.args)
