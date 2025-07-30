# DirTravler
# 🔍 DirTravler - Subdomain Discovery Automation Tool

**DirTravler** is a powerful and automated shell-based tool designed for **penetration testers**, **bug bounty hunters**, and **security researchers**. It focuses on **collecting subdomains** from a list of target domains provided in `domains.txt` using the industry-standard tool [`subfinder`](https://github.com/projectdiscovery/subfinder).

The APIs are good — really good — and they're here to reduce your work. But the problems begin when APIs fail to perform well. There are often numerous issues going on behind the scenes.

My name is Imran Niaz, and I’m a junior security researcher with five years of experience in Laravel, PHP, and security research. I love reading other people's code. Every day, I notice small mistakes developers leave in their comments — and from there, I can often access their servers.

On a daily basis, I scan millions of public and private IPs, collecting as much information as I can. This information is critical, especially when companies — even tech giants — offer services at a local or domestic level but still make vulnerable decisions in their architecture. These weaknesses can lead to massive destruction, including data breaches, API key leaks, and more.

We're also working on machine learning models designed to automatically identify these issues — even if they're hidden in variables, string fields, or other obscure places. These issues can be as basic as a misconfigured setting, or as severe as XSS (Cross-Site Scripting), CSRF, or insecure object references.

The harsh reality is this: code today is more vulnerable than ever. Developers are increasingly relying on AI and LLMs to write code, but they often don’t understand the hidden flaws these models introduce. As researchers, we dig into JavaScript files, configuration files, and even .git folders that are mistakenly left exposed.

## 🚀 Features

- ✅ Automatically extracts subdomains for multiple domains.
- ✅ Cleans domain input (strips http/https, slashes).
- ✅ Saves results for each domain in organized text files.
- ✅ Fast, silent, and ideal for chaining with tools like `httpx`, `nuclei`, and `dirsearch`.
- ✅ Fully scriptable and customizable for CI/CD and automation pipelines.

---

## 📌 Why DirTravler?

Penetration testers often need to **enumerate subdomains** quickly and reliably for hundreds of domains. This tool automates that process:

- 📁 Structured output (one file per domain).
- 🧠 Cleans up messy domain lists.
- 🧪 Finds attack surfaces (subdomains that may expose services or apps).
- 💡 Saves time and effort by integrating with your existing recon workflow.

---

## 🛠️ Requirements

- Linux / WSL environment
- `subfinder` must be installed (you already have it)
- Bash shell

---

## 📂 Folder Structure After Execution


> ✅ You can mix full domains, subdomains, or URLs — the script will clean them.

---

### 2. Run the script

```bash
chmod +x find_subdomains.sh
./find_subdomains.sh

cat urls.txt | httpx -title -status-code -web-server -ip -tech-detect -silent
