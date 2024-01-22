import hcl2
import sys
import json

def list_resource_names(tf_file_path):
    resources = []

    # Read the .tf file contents
    with open(tf_file_path, 'r') as file:
        tf_file_content = file.read()

    # Parse the contents using the python-hcl2 library
    try:
        parsed_tf_content = hcl2.loads(tf_file_content)
        # Iterate over the parsed content to find resource blocks
        for resource_block_list in parsed_tf_content.get('resource', []):
            for resource_type, resource_objs in resource_block_list.items():
                for resource_name in resource_objs:
                    resources.append({"type": resource_type, "name": resource_name})
    except Exception as e:
        print(f"An error occurred while parsing the file: {e}", file=sys.stderr)
        sys.exit(1)

    return resources

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python parse_tf_resources.py <path_to_tf_file>", file=sys.stderr)
        sys.exit(1)

    terraform_file_path = sys.argv[1]
    resources = list_resource_names(terraform_file_path)

    # Output each resource as a JSON object on a separate line
    for resource in resources:
        print(json.dumps(resource))
