# gh-workflow-keepalive

Prevent GitHub Actions scheduled workflows from being automatically disabled due to inactivity by periodically enabling them via the GitHub API.

## How to (As a User)

1. Clone this Repository

    ```bash
    git clone https://github.com/TheSpeedCubing/gh-workflow-keepalive.git
    cd gh-workflow-keepalive
    ```
	
2. Update `workflows.yml` as desired

    ```
	repos:
      your-org/your-repo:
        - a.yml
        - b.yml
      another-org/another-repo:
        - ci.yml
	```

3. Add GitHub classic token in `.env`

    ```
    GITHUB_TOKEN=XXX
    ```
	
4. Install yq

    ```
    wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
    chmod +x /usr/local/bin/yq
    ```
	
5. Start manually or via Cron

    ```
    # Make the script executable
    chmod +x gh-workflow-keepalive/run.sh
    chmod +x gh-workflow-keepalive/run_and_log.sh
    
    # Run manually
    ./run_and_logsh
    
    # cron
    (crontab -l 2>/dev/null; echo "0 0 * * * /home/debian/gh-workflow-keepalive/run_and_log.sh") | crontab -
    ```
