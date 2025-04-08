import json
import subprocess
import logging

def consolidate_manifest(config:dict):
    build_variants = config["variants"]
    images = config["components"].keys()
    for image in images:
        for version in config["versions"]:
            # tags to consolidate
            tags = config["versions"][version]["tags"]

            for tag in tags:
                logging.info("Consolidating docker image: %s with tag: %s", image, tag)
                manifest_images = []

                for variant in build_variants:
                    if variant == "default":
                        manifest_images.append(f"--amend bureau14/{image}:{tag}")
                    else:
                        manifest_images.append(f"--amend bureau14/{image}:{tag}-{variant}")

                create_command = f"docker manifest create bureau14/{image}:{tag} " + " ".join(manifest_images)
                push_command = f"docker manifest push bureau14/{image}:{tag}"

                for command in [create_command, push_command]:
                    logging.info("Executing command: %s", command)
                    output = subprocess.run(command.split(), capture_output=True, text=True)
                    if output.returncode != 0:
                        logging.error("Command failed with: %s", output.stderr)
                        raise Exception(f"Command failed: {command}")
                    else:
                        logging.info("Command succeeded: %s", command)
    logging.info("Manifest consolidation completed successfully.")
                        

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    config_file = "config.json"
    with open(config_file, "r") as file:
        config = json.load(file)
        consolidate_manifest(config)