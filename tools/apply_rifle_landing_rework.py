import json
import os
from pathlib import Path

def main():
    # Derive repo root from the script's location
    repo_root = Path(__file__).resolve().parents[1]
    
    # Load project JSON
    project_path = repo_root / "tests" / "phone_gate" / "phone_gate.project.json"
    with open(project_path, "r") as f:
        data = json.load(f)
    
    # Load starterpack fragment
    fragment_path = repo_root / "tools" / "starterpack_fragment.json"
    with open(fragment_path, "r") as f:
        fragment_data = json.load(f)
    
    # Modify project data
    data["tree"]["Workspace"]["SpawnLocation"]["$properties"]["CanCollide"] = False
    data["tree"]["Workspace"]["SpawnLocation"]["$properties"]["Position"] = [0, 3, 15]
    
    # Set StarterPack to the entire fragment object
    data["tree"]["StarterPack"] = fragment_data
    
    # Write back project JSON with indent 2 and final newline
    with open(project_path, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
    
    print(str(project_path))

if __name__ == "__main__":
    main()
