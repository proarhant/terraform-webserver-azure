import sys
import time
from urllib.error import HTTPError, URLError
import urllib.request
import logging
from logging.handlers import TimedRotatingFileHandler

# Configure logs to roll over at midnight everyday
# Log entries contain timestamp, log level (e.g INFO, ERROR) and message
logger = logging.getLogger()
logger.setLevel(logging.INFO)
file_handler = TimedRotatingFileHandler("healthcheck_webapp.log", when="midnight", interval=1)
file_handler.suffix = "%Y%m%d"
file_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logger.addHandler(file_handler)

# In the production, we will use HTTPS.
WEB_PROTOCOL = "HTTP"
#WEBAPP_ENDPOINT = "127.0.0.1"
#PERIOD = 5
WEB_NGINX_DOWN = "<urlopen error [Errno 111] Connection refused>"
WEB_HOST_DOWN = "<urlopen error timed out>"
WEB_NGINX_FORBIDDEN = "HTTP Error 403: Forbidden"

#Health check displays SUCCESS if the webapp URL returns Hello World!.
def health_check(argv):
    try:
        host_ip = argv[1]
        url = WEB_PROTOCOL+"://" + host_ip
        logger.info("Health check webapp at %s", url)

        response=urllib.request.urlopen(url, timeout=7)
        if response:
            if response.getcode()==200:
                # HTTP status 200 indicates we have the Nginx server is serving. 
                lines = response.readlines()
                logger.info("Webserver is UP and returns HTTP code: " + str(response.getcode()))
                if lines is not None:
                    #logger.info("Debugging contents: "+str(lines[0].decode('utf-8')).rstrip())
                    for line in lines:
                        # SUCCESS if the index.html contains the "Hello World!" text. Otherwise, the Nginx server is still being provisioned...
                        if 'Hello World!' in str(line):
                            logger.info("Webapp index file content is: " + str(line.decode('utf-8')).rstrip())
                            logger.info("Hello World app health check SUCCESS.")
                            return True
                    # Nginx server is being provisioned. index.html is not ready yet.
                    logger.info("Hello World app is being deployed...")
                else:
                     # Nginx server is being provisioned. index.html is not ready yet with the content "Hello World!"
                    logger.info("Hello World app is being deployed...")
            else:
                logger.info("Webserver is NOT healthy. Returns HTTP code: " + str(response.getcode()))
    except (HTTPError, URLError) as error:
        logging.error('HTTP response not received because %s for URL: %s', error, url)  
        if str(error) == WEB_NGINX_DOWN:
            logging.error('Nginx process is not running.')
        elif str(error) == WEB_HOST_DOWN:
            logging.error('Webserver host is currently NOT Reachable. E.g. Host is down.')
        elif str(error) == WEB_NGINX_FORBIDDEN:
            logging.error('NGINX is currently NOT serving. E.g. index.html is missing.')
    except Exception as e:
        logger.error("Webserver health check failure %s " %(str(e)))
    return False

#Health check periodically
if __name__ == '__main__':
    while True:
        logger.info("START: Health check starts...")
        if not health_check(sys.argv):
            logger.info("Health check FAILED.")
        pass
        logger.info("END: Health check finished.\n")
        PERIOD = int(sys.argv[2])
        time.sleep(PERIOD)
    pass
