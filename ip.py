# prompt: write an scrpt wher i wil provide the  ip adress adn  i will scan all rand nad also status OF IP ADRESS also it will scan and show me whats going on with out using nmap i will  give command run on terminal like  pyhhon ip.py 149.20.189.155 

import sys
import subprocess

def scan_ip_info(ip_address):
    """
    Scans an IP address and provides basic information and status using system tools.

    Args:
        ip_address: The IP address to scan.
    """
    print(f"Scanning IP address: {ip_address}")

    # Check if the IP is reachable using ping
    print("\nChecking reachability (ping):")
    try:
        # Use subprocess to run the ping command
        # -c 4: send 4 packets (Linux/macOS)
        # -n 4: send 4 packets (Windows)
        ping_command = ['ping', '-c', '4', ip_address]
        # For Windows, use ['ping', '-n', '4', ip_address]
        if sys.platform.startswith('win'):
            ping_command = ['ping', '-n', '4', ip_address]

        result = subprocess.run(ping_command, capture_output=True, text=True, timeout=10)
        print(result.stdout)
        if result.returncode == 0:
            print("Status: IP is reachable.")
        else:
            print("Status: IP is likely unreachable.")
    except FileNotFoundError:
        print("Error: 'ping' command not found. Make sure it's in your system's PATH.")
    except subprocess.TimeoutExpired:
        print("Ping timed out.")
    except Exception as e:
        print(f"An error occurred during ping: {e}")

    # Get host information using nslookup
    print("\nGetting host information (nslookup):")
    try:
        nslookup_command = ['nslookup', ip_address]
        result = subprocess.run(nslookup_command, capture_output=True, text=True, timeout=10)
        print(result.stdout)
        if result.returncode != 0 and "can't find" in result.stderr:
             print("No host information found for this IP.")
    except FileNotFoundError:
        print("Error: 'nslookup' command not found. Make sure it's in your system's PATH.")
    except subprocess.TimeoutExpired:
        print("Nslookup timed out.")
    except Exception as e:
        print(f"An error occurred during nslookup: {e}")

    # You can add more system commands here to gather additional information
    # For example, using 'traceroute' (Linux/macOS) or 'tracert' (Windows)
    # print("\nChecking traceroute:")
    # try:
    #     traceroute_command = ['traceroute', ip_address]
    #     if sys.platform.startswith('win'):
    #          traceroute_command = ['tracert', ip_address]
    #     result = subprocess.run(traceroute_command, capture_output=True, text=True, timeout=10)
    #     print(result.stdout)
    # except FileNotFoundError:
    #     print("Error: 'traceroute'/'tracert' command not found.")
    # except subprocess.TimeoutExpired:
    #     print("Traceroute/tracert timed out.")
    # except Exception as e:
    #     print(f"An error occurred during traceroute/tracert: {e}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python ip.py <ip_address>")
        sys.exit(1)

    ip_address_to_scan = sys.argv[1]
    scan_ip_info(ip_address_to_scan)
