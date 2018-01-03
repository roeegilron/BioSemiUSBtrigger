classdef BioSemiSerialPort
    % BioSemiSerialPort - function send triggers to BioSemi EEG systems 
    % This function requires the purchase (or manufacture) of a USB to serial 
    % hardware device. 
    % https://www.biosemi.com/faq/USB%20Trigger%20interface%20cable.htm
    %
    % Syntax:  sp = BioSemiSerialPort();
    %
    % Inputs: none.  
    %
    % Outputs: sp - serial port object 
    %
    % Example:
    %    sp = BioSemiSerialPort(); % open serial port 
    %    sp.testTriggers; % test pins 1-8 
    %    sp.sendTrigger(5); % send trigger '5' to eeg system  
    %    sp.findSerialPortName(); % for troubleshoot if not connecting
    %    properly
    % Other m-files required: none
    % Subfunctions: none
    % MAT-files required: none
    % Toolboxes requires: instrument control toolbox 
    %
    % See also: instrhwinfo,instrreset,serial 
    
    % Version:  v1.0
    % Date:     Dec-19 2017, 10:00 AM PST
    % Author:   Roee Gilron, UCSF, SF, CA.
    % URL/Info: github.com/roeegilron/biosemitrigger
    
    properties
        sp
    end
    % The internal data implementation is not publicly exposed
    properties (Access = 'protected')
        props = containers.Map;
    end
    methods (Static = true)
        function portnames = getPortNames()
            % set serial port names for each os, may need modifcation
            portnames.mac = '/dev/cu.usbserial-DN17M98C';
            portnames.pc = 'COM3';
            portnames.linux = '/dev/cu.usbserial-DN17M98C';
        end
    end
    methods
        % Overload property names retrieval
        function names = properties(obj)
            names = fieldnames(obj);
        end
        % Overload clspass object display
        function disp(obj)
            disp([obj.props.keys', obj.props.values']);  % display as a cell-array
        end
        function obj = BioSemiSerialPort(~)
            sp = [];
            instrreset
            serialInfo = instrhwinfo('serial');
            avportst = serialInfo.AvailableSerialPorts;
            pnms = obj.getPortNames;
            % get serial port name(serial COM name different across OS's)
            if ismac % mac systems
                % check to see if cable is connnected
                sercheck  = cellfun(@(x) any(strfind(x,pnms.mac)),...
                    avportst);
            elseif ispc  % pc's
                sercheck  = cellfun(@(x) any(strfind(x,pnms.pc)),...
                    avportst);
            elseif isunix & ~ismac % linux ?
                sercheck  = cellfun(@(x) any(strfind(x,pnms.linux)),...
                    avportst);
            end
            % open serial port
            if sum(sercheck) == 0
                error('trigger cable not connected');
            else
                obj.sp = serial(avportst{sercheck},....
                    'BaudRate',115200,...
                    'DataBits',8,...
                    'StopBits',1);
                fopen(obj.sp);
                if isvalid(obj.sp)
                    fprintf('succesfully connected to serial port %s\n',obj.sp.Port);
                end
            end
            
        end
        function findSerialPortName(obj)
            fprintf('Serial port have different names in each OS\n');
            fprintf('This process helps you discover serial port name for BioSemi Cable on your OS\n');
            fprintf('Make sure you have your cable and its not connected OS\n');
            takemeasure = 0;
            while takemeasure == 0
                takemeasure = input('is cable idsconnected?\n(1 = yes)');
                pause(3);% makes sure if cable disconnected recently it is purged
                instrreset
                serialInfo = instrhwinfo('serial');
                avportst1 = serialInfo.AvailableSerialPorts;
            end
            fprintf('All connected serial objects recorded\n');
            fprintf('Now please connect BioSemi trigger cable\n');
            
            takemeasure = 0;
            while takemeasure == 0
                takemeasure = input('is cable connected?\n(1 = yes)');
                pause(3); % gives system time to load driver 
                instrreset
                serialInfo = instrhwinfo('serial');
                avportst2 = serialInfo.AvailableSerialPorts;
            end
            fprintf('\n\n BioSemi serial port name is:\n')
            cellfun(@(x) fprintf('%s\n',x),setxor(avportst1,avportst2))
            fprintf('Please check one of these strings matches correct OS on lines 40-42\n')
        end
        function wipePorts(obj)
            instrreset
        end
        function testTriggers(obj)
            for i = 1:7
                fwrite(obj.sp,uint8(2^i))
                pause(0.2);
            end
        end
        function sendTrigger(obj,code)
            try
                fwrite(obj.sp,uint8(code))
                if code > 255
                    warning('This cable only supports triggers in the range of 1-255 (int) - 8 bits');
                end
            catch
                if ~isvalid(obj.sp) % calbe not connected
                    error('cable is not connected anymore / was disconneted. Please delete object and reconnect cable'); 
                end
            end
        end
    end
end
