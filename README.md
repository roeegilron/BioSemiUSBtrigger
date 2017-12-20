# BioSemiUSBtrigger
Interface to send triggers to BioSemi system 
BioSemiSerialPort - function send triggers to BioSemi EEG systems 
This function requires the purchase (or manufacture) of a [USB to serial 
hardware device](https://www.biosemi.com/faq/USB%20Trigger%20interface%20cable.htm). 


`sp = BioSemiSerialPort(); % open serial port ` 

`sp.testTriggers; % test pins 1-8` 

`sp.sendTrigger(5); % send trigger '5' to eeg system` 

`sp.findSerialPortName(); % for troubleshooting if not connecting properly` 
