from urllib.parse import urlparse as parse
import urllib.request as req
import argparse
import re
import sys

def find_xss(body):
    xss_list = []
    pattern = re.compile(r'(innerHTML|innerText|textContent|eval)', re.IGNORECASE)
    for m in pattern.finditer(body):
        start = max(m.start() - 20, 0)
        end = min(m.end() + 27, len(body))
        snippet = body[start:end]
        xss_list.append(snippet)
    return xss_list

parser = argparse.ArgumentParser()
parser.add_argument("-u", "-url", "-l", "-link", dest="url", help="Target URL")
args = parser.parse_args()

if args.url:
    url = args.url
else:
    url = input("URL: ")

if not url.startswith("http://") and not url.startswith("https://"):
    url = "http://" + url

print("\nstarting NetHacker webot (NhBot) v1.2.5\n")

domain = parse(url)
domain = f"{domain.scheme}://{domain.netloc}"
print("TARGET URL DOMAIN: " + domain + "\n")

visited = set()
src_links = []

def bot(link):
    if link in visited:
        return
    visited.add(link)
    try: 
        print("TARGET URL: " + link)
        with req.urlopen(req.Request(link, headers={"User-Agent": "NetHacker Web Scraper NhBot v1.2.5"})) as resp:
            body = resp.read().decode("utf-8", errors="replace")
            dictHeaders = dict(resp.getheaders())
            headers = str(dictHeaders).replace(",", ", \n")
            status = str(resp.status)

        print("\nRESPONSE:")
        print("HTTP STATUS CODE: " + status + "\n")
        print("RESPONSE HEADERS:")
        print(headers + "\n")

        print("Content-Security-Policy:", "True" if "Content-Security-Policy" in dictHeaders else "False")
        print("X-Frame-Options:", "True" if any(k.lower() == "x-frame-options" for k in dictHeaders) else "False")
        
        print("\nRESPONSE BODY:")
        print(body + "\n")

        print("XSS-RELATED CODE SNIPPETS FOUND:")
        print(find_xss(body))
        print()

        matches = re.findall(r'src\s*=\s*[\'"]([^\'"]+)[\'"]', body)
        for m in matches:
            src_links.append(m)
    except Exception as err:
        print("NhBot on ERROR:", str(err) + "\n")

bot(url)

for i in src_links:
    if i.startswith("http://") or i.startswith("https://"):
        full_url = i
    elif i.startswith("/"):
        full_url = domain + i
    else:
        full_url = domain + "/" + i
    print("SOURCE URL IN RESPONSE BODY:", full_url + "\n")
    bot(full_url)

input("PRESS ENTER TO EXIT")
