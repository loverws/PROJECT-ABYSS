import json
import os
import sys

def main():
    repo_root = "C:\\LEOS_Games\\PROJECT_ABYSS"
    test_file_path = os.path.join(repo_root, "tests", "phone_gate", "phone_gate.project.json")
    
    try:
        with open(test_file_path, "r") as f:
            data = json.load(f)
        
        workspace = data["tree"]["Workspace"]
        floor = workspace["Floor"]
        
        assert floor["$className"] == "Part", f"Expected Floor to be Part, got {floor['$className']}"
        assert floor["$properties"]["Anchored"] is True, f"Expected Floor.Anchored to be True, got {floor['$properties']['Anchored']}"
        assert floor["$properties"]["CanCollide"] is True, f"Expected Floor.CanCollide to be True, got {floor['$properties']['CanCollide']}"
        
        floor_top_y = floor["$properties"]["Position"][1] + floor["$properties"]["Size"][1] / 2
        
        spawn = workspace["SpawnLocation"]
        assert spawn["$className"] == "SpawnLocation", f"Expected SpawnLocation to be SpawnLocation, got {spawn['$className']}"
        assert spawn["$properties"]["Position"][1] > floor_top_y, f"Expected SpawnLocation.Y > Floor.TopY, got {spawn['$properties']['Position'][1]} <= {floor_top_y}"
        
        target_names = ["Target1", "Target2", "Target3"]
        for name in target_names:
            target = workspace.get(name)
            assert target is not None, f"Expected {name} to exist"
            assert target["$className"] == "Part", f"Expected {name} to be Part, got {target['$className']}"
            assert target["$properties"]["Anchored"] is True, f"Expected {name}.Anchored to be True, got {target['$properties']['Anchored']}"
            transparency = target["$properties"].get("Transparency", 0)
            assert transparency != 1, f"Expected {name}.Transparency != 1, got {transparency}"
        
        print("GREYBOX_SPAWN_TEST_PASS")
        sys.exit(0)
        
    except (FileNotFoundError, json.JSONDecodeError, KeyError, TypeError, AssertionError) as e:
        print("FAIL")
        sys.exit(1)

if __name__ == "__main__":
    main()