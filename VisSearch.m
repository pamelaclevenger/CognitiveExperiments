%Search using polar
% Experiment by Pamela Clevenger
% February 7, 2016
% Anton Wu, Danny Foody, Conor Johnson



%% Get subject number and Condition
% Get Subject Number
subj_num = input('Enter Subject Number:   ');
double_check = lower(input(['You entered ' num2str(subj_num) ' as the Subject Number. Is this correct? (y/n): '],'s'));
while 1
    if double_check == 'y'
        break
    elseif double_check == 'n'
        subj_num = input('Enter Subject Number:   ');
    end
    double_check = lower(input(['You entered ' num2str(subj_num) ' as the Subject Number. Is this correct? (y/n): '],'s'));
end

condition = input('Enter Condition:   ');
double_check = lower(input(['You entered ' num2str(condition) ' as the Condition. Is this correct? (y/n) (REMEMBER, CONDITION MUST BE BETWEEN 1 AND 4): '],'s'));
while 1
    if double_check == 'y'
        break
    elseif double_check == 'n'
        condition = input('Enter Condition:   ');
    end
    double_check = lower(input(['You entered ' num2str(condition) ' as the Condition. Is this correct? (y/n) (REMEMBER, CONDITION MUST BE BETWEEN 1 AND 4): '],'s'));
end


%% initialize
today = num2str(date); %Today's date, for marking the subject data file

% Here we call some default settings for setting up Psychtoolbox
% Screen('Preference', 'SkipSyncTests', 1);
%Screen('Preference', 1);
PsychDefaultSetup(2);
rng('default');
rng('shuffle');

screens = Screen('Screens');
screenNumber = max(screens);

black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
grey = white/2;

% PsychDebugWindowConfiguration % for debugging

% Open an on screen window and color it grey
% For help see: Screen OpenWindow?
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
XLeft = windowRect(RectLeft);	 
XRight = windowRect(RectRight);
YTop = windowRect(RectTop);		
YBottom = windowRect(RectBottom);
ifi = Screen('GetFlipInterval', window);
HideCursor;

trials_per_block = 64; %
num_blocks = 16; %10;  % Experimental blocks
tot_trials = num_blocks * trials_per_block;
%tot_trials = num2str(num_blocks * trials_per_block);
tot_blocks = num2str(num_blocks);

if mod(condition,2) == 0;%Conditions 2 and 4 are unconnected
    theImage = imread('above.jpg');
    invertedImage = flipud(imread('above.jpg'));
else % conditions 1 and 3 are connected
    theImage = imread('above_connected.jpg');%NOTE TO PAM: MAKE SURE YOU GET THE RIGHT IMAGE HERE
    invertedImage = flipud(imread('above_connected.jpg')); % AND HERE
end

imagesize = size(theImage);
scaling_factor = 0.6;
scale = imagesize(1) * scaling_factor;

%% Data Structure

% Create DATA structure with the stuff I care about.
DATA=repmat(struct('condition', '--', 'conn_unconn','--','target','--',...
    'setsize','--','above_below','--','dist_locs','--','targ_loc','--',...
    'Key_map','--','block','--','RT','--','acc','--', 'pract','--'),1,tot_trials);

% condition: 1 = touching, all same; 2 = unconnected all same; 3 = touching randomized; 4 = unconnected randomized
% target: 1 = present, 0 = absent
% setsize: 2, 4 , 8 , 12
% above_below : 1 = above, 0 = below.  This will only matter in the conditions where the targets change.
% dist_locs: set of locations where distractors appeared % just record, don't manipulate
% targ_loc: name target location % randomize and record
% targ_name: 1 = plus above minus; 2 = minus above plus
% key_map: 1 (subj_num is odd) = (Present = '/', Absent = 'z'),
%     2 (subj_num is even) = (Absent = 'z', Present = '/')
% resp: subject response (responded present or absent on this trial)
% RT: Response time from onset if correct
% acc: Trial was accurate
% pract: 1 = this was a practice trial, 0 = this was an experimental trial

% Copy DATA to DUMMY for counterbalancing.
DUMMY = DATA;

%%%%%%% Counterbalance %%%%%%%%

% Counterbalance:
% (1) target presence (pres, abs)
% (2) setsize (2,4,6,8),
% (3) above/below (0,1)

%0 1 2
%0 0 2
%0 1 4
%0 0 4
%0 1 8
%0 0 8
%0 1 12
%0 0 12
%1 1 2
%1 0 2
%1 1 4
%1 0 4
%1 1 8
%1 0 8
%1 1 12
%1 0 12

for i = 1: tot_trials;
    DUMMY(i).condition = condition; % record condition
    DUMMY(i).target = mod(i,2); % present or absent
    DUMMY(i).setsize = mod(i,4); % setsize
    
    % if you're in the condition where above/below stays the same on every trial:
    if DUMMY(i).condition < 3;
        DUMMY(i).above_below = mod(subj_num,2); %make sure it's the same on every trial, but different among participants
    else %if above_below changes on every trial:
        DUMMY(i).above_below = mod(i,16);
    end
    
end

% Fix counterbalancing
% I want one target absetn and one target present trial for each set size.
% That looks like:
%0 1 2
%0 0 2
%0 1 4
%0 0 4
%0 1 8
%0 0 8
%0 1 12
%0 0 12
%1 1 2
%1 0 2
%1 1 4
%1 0 4
%1 1 8
%1 0 8
%1 1 12
%1 0 12


% The code below takes the setsize column I created and makes it into the
% setsize column described (that I want)
for i=1:trials_per_block;
    
    %Fix target counterbalancing (To get setsizes 22 44 66 88)
    if DUMMY(i).setsize == 0;
        DUMMY(i).setsize = 4;
    end
    if DUMMY(i).setsize < 3;
        if i<4;
            DUMMY(i).setsize=2;
        elseif i >4;
            if DUMMY(i-4).setsize == 2;
                DUMMY(i).setsize = 8;
            else
                DUMMY(i).setsize = 2;
            end
        end
    elseif DUMMY(i).setsize >2;
        if i<4;
            DUMMY(i).setsize=4;
        elseif i >4;
            if DUMMY(i-4).setsize == 4;
                DUMMY(i).setsize = 12;
            else
                DUMMY(i).setsize = 4;
            end
        end
    end
end;

% The code below takes the above_below column I created and makes it into the
% above_below column described (that I want)
for i=1:trials_per_block;
    
    %Fix target counterbalancing (To get setsizes 22 44 66 88)
    if DUMMY(i).above_below < 9;
        DUMMY(i).above_below = 0;
    else
        DUMMY(i).above_below = 1;
    end
end



% Create all blocks and randomize trials within blocks.
for i = 1:num_blocks;
    sequence = randperm(trials_per_block);
    DUMMYTOO = DUMMY(sequence);
    if i == 1;
        for i = 1:trials_per_block;
            DATA(i) = DUMMYTOO(i);
        end
        
    else
        for k = 1:trials_per_block;
            DATA((i-1)*trials_per_block+k)=DUMMYTOO(k);
        end
    end
end;

   
% Number the trials.
% and randomize keymap by participant so it's not confounded with above/below
Key_map = randi([1,2],1);
connectedness = mod(condition,2); % 0 = unconnected, 1 = connected

for n = 1:tot_trials;
    DATA(n).trial = n;
    DATA(n).Key_map = Key_map;
    DATA(n).conn_unconn = connectedness;
end

clear DUMMY;
clear DUMMYTOO;
clear PRACT_DUMMY;
clear DUMMYTHREE;


%% Key mappings
escape_key = KbName('ESCAPE');

% Define keymapping based on coinflip (as described above)
if mod(subj_num,2) == 0; 
    DATA(1).key_map = 1;
else 
    DATA(1).key_map = 2; 
end

% Map the keys for each keymapping    
if DATA(1).key_map == 1;
    present_key = KbName('m');
    absent_key = KbName('z');
    present_instr = 'm';
    absent_instr = 'z';
    
elseif DATA(1).key_map == 2;
    present_key = KbName('z');
    absent_key = KbName('m');
    present_instr = 'z';
    absent_instr = 'm';
end

%% Prepare Data File


if subj_num < 10;
    data_file = fopen(['Subject_0' num2str(subj_num) '_variedsearch_', today,'.txt'],'a');
else
    data_file = fopen(['Subject_' num2str(subj_num) '_variedsearch_',today, '.txt'],'a');
end


% Print header
fprintf(data_file,'\n%-5s\t %-5s\t %-5s\t %-5s\t %-5s\t %-5s\t %-5s\t %-5s\t %-5s\t %-5s\t %-5s\t %-5s\t',...
    'Subject','Condition','Keymap','Trial','block','pract','conn_unconn','resp','targ','Setsize','ACC','RT');


%% Instructions

Screen('TextSize', window, 25);
Screen('TextFont', window,'Calibri');

Screen('DrawText',window,'On each trial, you will see a target, followed by a search array.',XLeft+10,YBottom - 500,black);
Screen('DrawText',window,'Your job is to look for the target in the search array.',XLeft+10,YBottom - 460,black);
Screen('DrawText',window,['If you see a target in the array, press ' present_instr] ,XLeft+10,YBottom - 340,black);
Screen('DrawText',window,['If you do not see a target in the array, press ' absent_instr] ,XLeft+10,YBottom - 300,black);
Screen('DrawText',window,'You will be given breaks after each block of trials. Please briefly rest during these breaks.',XLeft+10,YBottom - 200,black);
Screen('DrawText',window,'Now, you''ll complete a block of practice trials to get used to the experiment.',XLeft+10,YBottom - 140,black);
Screen('DrawText',window,'Please alert the experimenter once the practice trials have finished.',XLeft+10,YBottom - 100,black);
Screen('DrawText',window,'Press any key when ready to start the practice trials.',XLeft+10,YBottom - 40,black); 

Screen('Flip',window);

KbWait;



%% Define a trial; and run the trials

block_number = 1;
for i = 1:tot_trials;
    acc_feedback = false; %default
    DATA(i).block = block_number; %save blocknum to data
    
    %if block_number < 3; % the first two blocks are practice
    if DATA(i).trial < 16;
        acc_feedback = true;
        DATA(i).pract = 1;
    else
        acc_feedback = false;
        DATA(i).pract = 0;
    end
    
    % Post practice instructions
    if DATA(i).trial == 16;
        %instructions
        Screen('DrawText',window,'You have finished the practice trials. Now you will begin the experiment',XLeft+10,YBottom - 500,black);
        Screen('DrawText',window,['Press this key: ', present_instr, '  when you see the target and this key: ', absent_instr, '  if it is not there'].',XLeft+10,YBottom - 420,black);
 
        Screen('DrawText',window,'You will be given breaks after each block of trials. Please briefly rest during these breaks.',XLeft+10,YBottom - 200,black);
        Screen('DrawText',window,'Now is the time to ask the experimenter any questions you have before you begin.',XLeft+10,YBottom - 140,black);

        Screen('DrawText',window,'Press any key when you are ready to start the experiment.',XLeft+10,YBottom - 40,black);

        Screen('Flip',window);

        KbWait;
    end

    
    %Take a break after every block 
    if mod(DATA(i).trial, trials_per_block)==0;
        blocks_complete = num2str(block_number);
        block_number = block_number + 1;
        if DATA(i).trial > 16
        blocks_left = num2str((tot_trials/trials_per_block)-block_number);
        %Let subjects know how much they've completed thus far
        trials_left = tot_trials- (DATA(i).trial);
        percent_complete = round((DATA(i).trial)/tot_trials);
        Screen('TextSize', window, 30);
            Screen('TextFont', window,'Calibri');
            Screen('DrawText',window,'Now you can take a break and rest.',XLeft + 10,YBottom - 420,black);
            %Screen('DrawText',window,'You have completed ', percent_complete,'% of the experiment so far.'.',XLeft + 10,YBottom - 220,black)
            Screen('DrawText',window,['You have completed ', blocks_complete, ' block(s) out of ', tot_blocks, ' total blocks.'],XLeft + 10,YBottom - 380,black);
            Screen('DrawText',window,['Remember, Press ', present_instr, '  when you see the target or press ', absent_instr, '  if it is not there'].',XLeft+10,YBottom - 300,black);

            Screen('DrawText',window,'Press any key to continue.',XLeft + 10,YBottom - 180,black);
            Screen('Flip',window);
            % Wait for input
            WaitSecs(4);
            KbWait;
        end   
    end
    
    %(1) Determine the set size and target for this trial
    stsz = DATA(i).setsize;

    % (1.1) define locations for different setsizes
    rotation = 180/stsz;
    upperbound = 360-rotation;
    stops = round(360/stsz);
    all_thetas = [0:stops:upperbound] + rotation; %count to 360 by 45, rotate by 22.5 degrees
    distance = 200; % distance from the center of screen.  For now it's hardcoded at 200
    
    % (1.2) determine target for this trial
    if DATA(i).above_below == 0; %rightside up target among upside down distractors
         targetimage = theImage;
    elseif DATA(i).above_below ==1; 
         targetimage = invertedImage; %upside down target
    end
    imageTexture = Screen('MakeTexture', window, targetimage);

    % (2) Draw the trial
    % (2.1) Target
    % Draw the target on the screen.  Display for 1000ms or until keypress,
    % whichever comes second.
    Screen('DrawTexture', window, imageTexture, [], [xCenter-(imagesize(1)*0.5), yCenter-(imagesize(1)*0.5), xCenter+(imagesize(1)*0.5), yCenter+(imagesize(1)*0.5)], 0,[],[],[grey])
    Screen('Flip', window);
    WaitSecs(1);
    
    %(2.2) Fixation cross
    Screen('FillOval', window, [black], [xCenter-5, yCenter-5, xCenter+5, yCenter+5]);
    Screen('Flip', window);
    WaitSecs(.5);

    while KbCheck; end;

    %(2.3) The stimuli 
    if DATA(i).target == 1; %target present
        targ = randi([1,stsz],1); %target one out of the items in the given setsize
        for j = 1:stsz; % Define locations and Flip the target 180 degrees and leave the rest/
            if j == targ;
                deg = 0;
            else
                deg = 180;
            end
            x = round(distance * cosd(all_thetas(j)) + xCenter); %x coordinate
            y = round(distance * sind(all_thetas(j)) + yCenter); %y coordinate
            imagelocation = [x - (0.4*scale), y - (0.5* scale), x + (0.4* scale), y + (0.5*scale)] + randi([-15,15],1);
            Screen('DrawTexture', window, imageTexture, [], imagelocation, deg,[],[],[grey]);
        end

    elseif DATA(i).target == 0; % target absent
        for j = 1:stsz;
            x = round(distance * cosd(all_thetas(j)) + xCenter); %x coordinate
            y = round(distance * sind(all_thetas(j)) + yCenter); %y coordinate
            imagelocation = [x - (0.4*scale), y - (0.5* scale), x + (0.4* scale), y + (0.5* scale)]  + randi([-15,15],1);
            Screen('DrawTexture', window, imageTexture, [], imagelocation, 180,[],[],[grey]);
        end
    end
    Screen('FillOval', window, [black], [xCenter-5, yCenter-5, xCenter+5, yCenter+5]);

    %(3) show the whole deal
    respToBeMade = true; % make sure you know you gotta wait for response
    Screen('Flip', window);
    start_trial = GetSecs;

    %(4) Collect this trial's datums
    while respToBeMade;
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(escape_key);
            fclose(data_file);
            ShowCursor;
            sca;
            return
        else 
            if DATA(i).target == 1;
                if keyCode(present_key);
                    DATA(i).resp = 1;
                    DATA(i).acc = 1;
                    end_trial = GetSecs;
                    DATA(i).RT = end_trial - start_trial;
                    respToBeMade = false;
                elseif keyCode(absent_key);
                    DATA(i).resp = 0;
                    DATA(i).acc = 0;
                    respToBeMade = false;
                end                
            elseif DATA(i).target == 0;
                if keyCode(absent_key);
                    DATA(i).resp = 0;
                    DATA(i).acc = 1;
                    end_trial = GetSecs;
                    DATA(i).RT = end_trial - start_trial;
                    respToBeMade = false;
                elseif keyCode(present_key);
                    DATA(i).resp = 1;
                    DATA(i).acc = 0;
                    respToBeMade = false;
                end
            end
        end     
    end
    respToBeMade = false;

    if acc_feedback == true
        if DATA(i).acc == 1
            DrawFormattedText(window,'CORRECT','center','center',black);
        elseif DATA(i).acc == 0
            DrawFormattedText(window,'INCORRECT','center','center',black);
        end
        Screen('Flip',window);
        WaitSecs(.25);    
    end


    % How about display a blank screen for 500ms here?
    Screen('FillOval', window, [0 0 1], [xCenter-7, yCenter-7, xCenter+7, yCenter+7]);
    Screen('Flip', window);
    WaitSecs(.5);
    % Trial is over

    %Write your stuff to data file
    fprintf(data_file, '\n%-5s\t %-5s\t %-5s\t %-5s\t %-5s\t %-5s\t %-5s\t %-5s\t %-5s\t %-5s\t %-5s\t %-5s\t',...
        num2str(subj_num),num2str(DATA(i).condition), num2str(DATA(i).Key_map),num2str(DATA(i).trial),...
        num2str(DATA(i).block),num2str(DATA(i).pract),num2str(DATA(i).conn_unconn), num2str(DATA(i).resp),...
        num2str(DATA(i).target),num2str(DATA(i).setsize), num2str(DATA(i).acc),num2str(DATA(i).RT));

    if DATA(i).trial == tot_trials; % the very last trial
        Screen('DrawText',window,'You have completed the experiment',XLeft+20,YBottom - 500,black);
        Screen('DrawText',window,'Thank you for participating.',XLeft+20,YBottom - 460,black);

        Screen('DrawText',window,'You have made a valuable contribution to science!',XLeft+20,YBottom - 380,black);
        Screen('DrawText',window,'(You can leave now)',XLeft+20,YBottom - 80,black);
        Screen('Flip',window);
        WaitSecs(.5);
        KbWait;
        sca;
        return
    end  
end

fclose(data_file);

 