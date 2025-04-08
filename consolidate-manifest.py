import json
import subprocess
import logging
import click


def _check_if_variant_has_required_binaries(
    variant_binaries: list, required_binaries: list
) -> bool:
    for required_binary in required_binaries:
        if required_binary not in variant_binaries:
            return False
    return True


def consolidate_manifest(config: dict) -> None:
    build_variants = config["variants"]
    images = config["components"]
    for image, required_binaries in images.items():
        for version in config["versions"]:
            # tags to consolidate
            tags = config["versions"][version]["tags"]

            for tag in tags:
                logging.info("Consolidating docker image: %s with tag: %s", image, tag)
                manifest_images = []

                for variant in build_variants:
                    # we skip core2 variant from the manifest
                    # core2 is meant for very old hosts, docker won't see difference between core2 and haswell
                    if variant == "core2":
                        logging.info("Skipping %s variant for %s image", variant, image)
                        continue

                    # we can't add variant to the manifest which doesn't exist
                    # not every variant for every image exists, e.g aarch64 for 3.13 doesn't have rest api image
                    # before creating manifest we need to check if the variant exists
                    if not _check_if_variant_has_required_binaries(
                        config["versions"][version][variant].keys(), required_binaries
                    ):
                        logging.warning(
                            "%s image for %s with tag %s not found", variant, image, tag
                        )
                        continue

                    logging.info(
                        "Found %s image for %s with tag %s", variant, image, tag
                    )
                    if variant == "default":
                        manifest_images.append(f"--amend bureau14/{image}:{tag}")
                    else:
                        manifest_images.append(
                            f"--amend bureau14/{image}:{tag}-{variant}"
                        )

                delete_command = f"docker manifest rm bureau14/{image}:{tag}"
                create_command = (
                    f"docker manifest create bureau14/{image}:{tag} "
                    + " ".join(manifest_images)
                )
                push_command = f"docker manifest push bureau14/{image}:{tag}"

                for command in [delete_command, create_command, push_command]:
                    logging.info("Executing command: %s", command)
                    output = subprocess.run(
                        command.split(), capture_output=True, text=True
                    )
                    if output.returncode != 0:
                        logging.error("Command failed with: %s", output.stderr)
                        raise Exception(f"Command failed: {command}")
                    else:
                        logging.info("Command succeeded: %s", command)
    logging.info("Manifest consolidation completed successfully.")


@click.command()
@click.option("--config-file", type=str, default="config.json")
def main(config_file):
    logging.basicConfig(level=logging.INFO)
    with open(config_file, "r") as file:
        config = json.load(file)
        consolidate_manifest(config)


if __name__ == "__main__":
    main()
