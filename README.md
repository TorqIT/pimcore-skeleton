# Pimcore Project Skeleton (Torq IT fork)

Forked from https://github.com/pimcore/skeleton.

## Setup

### Prerequisites:
- A Linux based system (or Windows Subsystem for Linux (WSL) if you are on Windows - see https://learn.microsoft.com/en-us/windows/wsl/install for more information)
- Docker Desktop (https://www.docker.com/products/docker-desktop/)

### Setup instructions
1. Clone the repository
2. Update the `name` property in `composer.json` to match your project's name
3. Update the `.env.stub` property `APP_NAME` to match your project's name
4. run `cat .env.stub > .env` to create the .env file where you can add secrets
5. Run `docker compose up -d` to build the Docker images and run the containers
6. By default, go to `localhost:8400` in your browser to access the Pimcore admin (port is controlled by the `WEB_EXTERNAL_PORT` environment variable). Use username `admin` and password `pimcore` to log in.

## Getting updates
We recommend forking this repository and using it as an upstream remote in order to get the latest updates and improvements.
