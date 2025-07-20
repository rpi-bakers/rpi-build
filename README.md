# rpi-build

This repository contains shell scripts for setting up and building environments for Raspberry Pi systems.

## Included Scripts

| Script      | Description                                 |
|-------------|---------------------------------------------|
| `env.sh`    | Script for configuring environment variables |
| `setup.sh`  | Script for initial setup procedures          |
| `build.sh`  | Main script to execute the build process     |

## Usage


### 1. Check and Edit Environment Variables (if needed)
Before running the setup script, review and modify `env.sh` as necessary to match your environment or requirements. For example, you may need to set paths, user names, or other variables:
```sh
vim env.sh
# or use your favorite editor
```

### 2. Initial Setup
Run the setup script to prepare the environment:
```sh
source ./setup.sh
```

### 3. Load Environment Variables
You do not need to manually run `source env.sh`, as other scripts will automatically load the required environment variables.

### 4. Execute Build
Start the build process with the following command:
```sh
./build.sh
```

## Notes
- These scripts are intended for use in Linux or WSL environments.
- If you encounter permission issues, grant execute permissions with:
	```sh
	chmod +x *.sh
	```
- For further details or available options, please refer to the comments within each script.

## License
This repository is licensed under the MIT License.

---
If you have any questions or need assistance, feel free to reach out!