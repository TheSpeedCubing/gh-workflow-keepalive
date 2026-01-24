# gh-workflow-keepalive

Prevent GitHub Actions scheduled workflows from being automatically disabled due to inactivity by periodically enabling them via the GitHub API.

## How to (As a User)

1. Clone this Repository

    ```bash
    git clone https://github.com/TheSpeedCubing/gh-actions-keepalive.git
    cd gh-actions-keepalive
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
    chmod +x keepalive.sh
    
    # Run manually
    ./keepalive.sh
    
    # Or set up a daily cron job (UTC 16:00)
    (crontab -l 2>/dev/null; echo "0 16 * * * cd /path/to/gh-actions-keepalive && ./keepalive.sh >> /path/to/gh-actions-keepalive/keepalive.log 2>&1") | crontab -
    ```