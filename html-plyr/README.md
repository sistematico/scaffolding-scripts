# HTML Plyr Icecast Player

## Usage

Create .env file in current foltder with the contents:
```
# Website Name
SITE_NAME="Ultra Radio"

# CloudFlare credentials
CLOUDFLARE_EMAIL="your_name@email.com"
CLOUDFLARE_TOKEN="your_cloudflare_global_api_token_here"
```

```bash
curl -sNL https://raw.githubusercontent.com/sistematico/scaffolding-scripts/main/html-plyr/install.sh | REPO="site.com.br" USER="sistematico" PW="password" EMAIL="your_email@email.com" TOKEN="your_token" bash
```