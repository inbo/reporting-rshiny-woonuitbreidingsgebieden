#!/bin/bash
# Stop Shiny
#!/bin/bash
if pgrep -x "java" > /dev/null
then
    echo "Running"
	pkill java
else
    echo "Stopped, nothing to do"
fi
