classdef ArmDynamicsTask < DisplayTask
%
% This display code for my task is based on Dan's and Eric's codes.-XS, 2016/12/27

    properties
        trialFailed = false;
        hitObstacleThisTrial = false;

        center

        target
        followThroughTarget
%         targetR
%         targetL
%         targetLeft
%         targetRight

        targetActive % reference to one of the above fields
%
%         channelLeft
%         channelRight

        cursor
        hold
        sound

        photobox

        commandMap % containers.Map : command string -> method handle
    end

    properties
        TargetCenter = 0;
%         TargetLeft = 1;
%         TargetRight = 2;
    end

    properties
        showHold = false;
    end

    methods
        function task = CurlFieldTask()
            task.name = 'CurlFieldTask';
            task.showHold = false;
            task.buildCommandMap();
        end

        function initialize(task, ~)
            task.center = Circle(0, 0, 0);
            task.center.hide();
            task.dc.mgr.add(task.center);

            task.target = RectangleGradientTarget();
            task.target.hide();
            task.dc.mgr.add(task.target);

%            task.followThroughTarget = RectangleGradientTarget();
%            task.followThroughTarget.hide();
%            task.dc.mgr.add(task.followThroughTarget;

%             task.targetR = RectangleGradientTarget();
%             task.targetR.hide();
%             task.dc.mgr.add(task.targetR);
% 
%             task.targetL = RectangleGradientTarget();
%             task.targetL.hide();
%             task.dc.mgr.add(task.targetL);

%             task.targetRight = RectangleGradientTarget();
%             task.targetRight.hide();
%             task.dc.mgr.add(task.targetRight);

%             task.targetLeft = RectangleGradientTarget();
%             task.targetLeft.hide();
%             task.dc.mgr.add(task.targetLeft);

%             task.channelLeft = PolygonObstacle();
%             task.channelLeft.hide();
%             task.dc.mgr.add(task.channelLeft);
%
%             task.channelRight = PolygonObstacle();
%             task.channelRight.hide();
%             task.dc.mgr.add(task.channelRight);

            task.cursor = CursorRound();
            task.cursor.hide();
            task.dc.mgr.add(task.cursor);

            task.hold = Rectangle(Inf,Inf,1,1);
            task.hold.hide();
            task.dc.mgr.add(task.hold);

            task.photobox = Photobox_rig42(task.dc.cxt, 1);
            task.photobox.off();
            task.dc.mgr.add(task.photobox);

            task.sound = AudioFeedback();
        end

        function cleanup(task, data) %#ok<INUSD,MANU>
        end

        function update(task, data)
            if isfield(data, 'handInfo')
                handInfo = data.handInfo;
%                 task.cursor.xc = handInfo.handX;
%                 task.cursor.yc = handInfo.handY;
                task.cursor.xc = handInfo.cursorX;
                task.cursor.yc = handInfo.cursorY;
                task.cursor.touching = handInfo.handTouching;
                task.cursor.seen = handInfo.handSeen;
                %task.cursor.show();
            end
        end

        function runCommand(task, command, data)
            if task.commandMap.isKey(command)
                fprintf('Running taskCommand %s\n', command);
                fn = task.commandMap(command);
                fn(data);
            else
                fprintf('Unrecognized taskCommand %s\n', command);
            end
        end

        function buildCommandMap(task)
            map = containers.Map('KeyType', 'char', 'ValueType', 'any');
            map('TaskPaused') = @task.pause;
            map('StartTask') = @task.start;
            map('InitTrial') = @task.initTrial;
            map('CenterOnset') = @task.centerOnset;
            map('CenterAcquired') = @task.centerAcquired;
            map('CenterSettled') = @task.centerSettled;
            map('CenterHeld') = @task.centerHeld;
            map('ObstacleOnset') = @task.obstacleOnset;
            map('DelayPeriodStart') = @task.delayPeriodStart;
            map('GoCueZeroDelay') = @task.goCueZeroDelay;
            map('GoCueNonZeroDelay') = @task.goCueNonZeroDelay;
            map('MoveOnset') = @task.moveOnset;
%             map('TargetShift') = @task.targetShift;
%             map('TargetJumpR') = @task.TargetJumpR;
%             map('TargetJumpL') = @task.TargetJumpL;
            map('TargetAcquired') = @task.targetAcquired;
            map('TargetSettled') = @task.targetSettled;
            map('TargetHeld') = @task.targetHeld;
            map('Success') = @task.success;
            map('FailureCenterFlyAway') = @task.failureCenterFlyAway;
            map('FailureTargetFlyAway') = @task.failureTargetFlyAway;
            map('FailureHitObstacle') = @task.failureHitObstacle;
            map('ITI') = @task.iti;
            map('CenterUnacquire') = @task.centerUnacquire;
            map('TargetUnacquire') = @task.targetUnacquire;
            map('HitObstacle') = @task.hitObstacle;
            map('ReleasedObstacle') = @task.releasedObstacle;

            task.commandMap = map;
        end

        function pause(task, ~)
            task.center.hide();
            task.target.hide();
            task.followThroughTarget.hide();
%             task.targetR.hide();
%             task.targetL.hide();
%             task.targetLeft.hide();
%             task.targetRight.hide();
            task.hold.hide();
%             task.channelLeft.hide();
%             task.channelRight.hide();
            task.cursor.hide();
            task.photobox.off();
        end

        function start(task, ~)
            task.cursor.show();
            task.photobox.off();
        end

        function initTrial(task, data)
            task.trialFailed = false;

            task.cursor.show();

            P = data.P;
            C = data.C;
            task.center.xc = C.centerX;
            task.center.yc = C.centerY;
            task.center.radius = P.centerSize/2 * 3;
            task.center.borderWidth = 0;
            task.center.borderColor = task.dc.sd.green;
            task.center.fill = true;
            task.center.fillColor = task.dc.sd.green;
            task.center.hide();

            task.hold.fill = false;
            task.hold.fillColor = task.dc.sd.red;
            task.hold.color = task.dc.sd.red;
            task.hold.borderWidth = 3;

%             yellow = [255 238 0] / 255;
%             yellowFill = [255 246 120] / 255;
            red = [1 0 0];
            redFill = [1 0.5 0.5];

            task.hitObstacleThisTrial = false;

%            task.followThroughTarget.pointsX = C.followTargetX;
%            task.followThroughTarget.pointsY = C.followTargetY; % XS-will match these with the positions of follow through targets sent by the the condition bus
%            task.followThroughTarget.depth = C.targetDepth;
%            task.followThroughTarget.theta = C.targetTheta;
%            task.followThroughTarget.width = C.followTargetWidth; % XS-will match these with the positions of follow through targets sent by the condition bus
%            task.followThroughTarget.contourWidth = 3;
%            task.followThroughTarget.contourColor = [0.3 1 0.3];
%            task.followThroughTarget.vibrateSigma = P.delayVibrateSigma;
%            task.followThroughTarget.hide();
%            task.followThroughTarget.normal();


%             if C.hasChannelLeft
%                 task.channelLeft.pointsX = C.channelLeftPointsX;
%                 task.channelLeft.pointsY = C.channelLeftPointsY;
%                 task.channelLeft.contourWidth = 3;
% %                 if P.obstacleCollisionPermitted
% %                     task.channelLeft.contourColor = yellow;
% %                     task.channelLeft.fillColor = yellowFill;
% %                     task.channelLeft.fillColorCollision = task.channelLeft.contourColor;
% %                 else
%                     task.channelLeft.contourColor = red;
%                     task.channelLeft.fillColor = redFill;
%                     task.channelLeft.fillColorCollision = task.channelLeft.contourColor;
% %                 end
%                 task.channelLeft.contour();
%                 task.channelLeft.vibrateSigma = 0;
%             end

%             if C.hasChannelRight
%                 task.channelRight.pointsX = C.channelRightPointsX;
%                 task.channelRight.pointsY = C.channelRightPointsY;
%                 task.channelRight.contourWidth = 3;
% %                 if P.obstacleCollisionPermitted
% %                     task.channelRight.contourColor = yellow;
% %                     task.channelRight.fillColor = yellowFill;
% %                     task.channelRight.fillColorCollision = task.channelRight.contourColor;
% %                 else
%                     task.channelRight.contourColor = red;
%                     task.channelRight.fillColor = redFill;
%                     task.channelRight.fillColorCollision = task.channelRight.contourColor;
% %                 end
%                 task.channelRight.contour();
%                 task.channelRight.vibrateSigma = 0;
%             end
%             task.channelLeft.hide();
%             task.channelRight.hide();

            task.target.xc = C.targetX;
            task.target.yc = C.targetY;
            task.target.theta = C.targetTheta;
            task.target.depth = C.targetDepth;
            task.target.width = C.targetWidth;
            task.target.contourWidth = 3;
            task.target.contourColor = [0.3 1 0.3];
            task.target.vibrateSigma = P.delayVibrateSigma;
            task.target.hide();
            task.target.normal();

%             if C.hasTargetR
%                 task.targetR.xc = C.jumpTargetX;
%                 task.targetR.yc = C.jumpTargetY;
%                 task.targetR.theta = C.jumpTargetTheta;
%                 task.targetR.depth = C.jumpTargetDepth;
%                 task.targetR.width = C.jumpTargetWidth;
%                 task.targetR.contourWidth = 3;
%                 task.targetR.contourColor = [0.3 1 0.3];
%                 task.targetR.vibrateSigma = P.delayVibrateSigma;
%                 task.targetR.normal();
%                 task.targetR.dim(P.inactiveTargetContrast);
%                 task.targetR.hide();
%             end
% 
%             if C.hasTargetL
%                 task.targetL.xc = C.jumpTargetX;
%                 task.targetL.yc = C.jumpTargetY;
%                 task.targetL.theta = C.jumpTargetTheta;
%                 task.targetL.depth = C.jumpTargetDepth;
%                 task.targetL.width = C.jumpTargetWidth;
%                 task.targetL.contourWidth = 3;
%                 task.targetL.contourColor = [0.3 1 0.3];
%                 task.targetL.vibrateSigma = P.delayVibrateSigma;
%                 task.targetL.normal();
%                 task.targetL.dim(P.inactiveTargetContrast);
%                 task.targetL.hide();
%             end


%             if C.hasTargetLeft
%                 task.targetLeft.xc = C.targetLeftX;
%                 task.targetLeft.yc = C.targetLeftY;
%                 task.targetLeft.theta = C.targetLeftTheta;
%                 task.targetLeft.depth = C.targetLeftDepth;
%                 task.targetLeft.width = C.targetLeftWidth;
%                 task.targetLeft.contourWidth = 3;
%                 task.targetLeft.contourColor = [0.3 1 0.3];
%                 task.targetLeft.vibrateSigma = P.delayVibrateSigma;
%                 task.targetLeft.normal();
%                 task.targetLeft.dim(P.inactiveTargetContrast);
%                 task.targetLeft.hide();
%             end
%
%             if C.hasTargetRight
%                 task.targetRight.xc = C.targetRightX;
%                 task.targetRight.yc = C.targetRightY;
%                 task.targetRight.theta = C.targetRightTheta;
%                 task.targetRight.depth = C.targetRightDepth;
%                 task.targetRight.width = C.targetRightWidth;
%                 task.targetRight.contourWidth = 3;
%                 task.targetRight.contourColor = [0.3 1 0.3];
%                 task.targetRight.vibrateSigma = P.delayVibrateSigma;
%                 task.targetRight.normal();
%                 task.targetRight.dim(P.inactiveTargetContrast);
%                 task.targetRight.hide();
%             end

            task.targetActive = task.target;

            task.photobox.off();
        end

        function centerOnset(task, ~)
            task.center.show();
            task.target.stopVibrating();
            task.target.hide();
            task.dc.log('Center Onset');
        end

        function centerAcquired(task, ~)
            task.center.fillColor = [0 1 1];
            task.dc.log('Center Acquired');
        end

        function centerUnacquire(task, ~)
            task.center.fillColor = task.dc.sd.green;
            task.dc.log('Center Unacquired');
            task.photobox.off();
        end

        function centerSettled(task, data) %#ok<INUSD>
%             P = data.P;
%             trialData = data.trialData;
%             if task.showHold
%                 task.hold.xc = trialData.holdX;
%                 task.hold.yc = trialData.holdY;
%                 task.hold.width = P.holdWindow;
%                 task.hold.height = P.holdWindow;
%                 task.hold.fill = false;
%                 task.hold.show();
%             end
            task.dc.log('Center Settled');
        end

        function centerHeld(task, ~)
            %task.center.success();
            task.hold.fill = true;
            task.dc.log('Center Held');
        end

        function obstacleOnset(task, data)
            C = data.C;

%             if C.hasChannelLeft
%                 task.channelLeft.normal();
%                 task.channelLeft.show();
%             end
%
%             if C.hasChannelRight
%                 task.channelRight.normal();
%                 task.channelRight.show();
%             end

            task.dc.log('Obstacle Onset');
        end

        function delayPeriodStart(task, data)
            C = data.C;
            task.target.contour();
            task.target.vibrate(); % XS-not sure if the target should vibrate together with the follow through target. TBD.
            task.target.show();
%            task.followThroughTarget.vibrate();
%            task.followThroughTarget.show();

%             if C.hasTargetLeft
%                 task.targetLeft.contour();
%                 task.targetLeft.vibrate();
%                 task.targetLeft.show();
%             end
%             if C.hasTargetRight
%                 task.targetRight.contour();
%                 task.targetRight.vibrate();
%                 task.targetRight.show();
%             end

%             if C.hasChannelLeft
%                 task.channelLeft.normal();
%                 task.channelLeft.show();
%             end
%             if C.hasChannelRight
%                 task.channelRight.normal();
%                 task.channelRight.show();
%             end
            task.photobox.on();

            task.dc.log('Delay Period Start');
        end

        function goCueZeroDelay(task, data)
            C = data.C;
            task.hold.hide();
            task.center.hide();
            task.target.stopVibrating();
            task.target.fill();
            task.target.show();
%            task.followThroughTarget.stopVibrate();
%            task.followThroughTarget.fill();
%            task.followThroughTarget.show();


%             if C.hasTargetLeft
%                 task.targetLeft.stopVibrating();
%                 task.targetLeft.fill();
%                 task.targetLeft.show();
%             end
%             if C.hasTargetRight
%                 task.targetRight.stopVibrating();
%                 task.targetRight.fill();
%                 task.targetRight.show();
%             end

%             if C.hasChannelLeft
%                 task.channelLeft.normal();
%                 task.channelLeft.show();
%             end
%             if C.hasChannelRight
%                 task.channelRight.normal();
%                 task.channelRight.show();
%             end

            task.photobox.flash();
            task.dc.log('Go Cue Zero Delay');
        end

        function goCueNonZeroDelay(task, data)
            C = data.C;
            task.hold.hide();
            task.center.hide();

            task.target.fill();
            task.target.stopVibrating();
            task.target.show();
%            task.followThroughTarget.stopVibrate();
%            task.followThroughTarget.fill();
%            task.followThroughTarget.show();


%             if C.hasTargetLeft
%                 task.targetLeft.stopVibrating();
%                 task.targetLeft.fill();
%                 task.targetLeft.show();
%             end
%             if C.hasTargetRight
%                 task.targetRight.stopVibrating();
%                 task.targetRight.fill();
%                 task.targetRight.show();
%             end

%             if C.hasChannelLeft
%                 task.channelLeft.stopVibrating();
%                 task.channelLeft.normal();
%                 task.channelLeft.show();
%             end
%             if C.hasChannelRight
%                 task.channelRight.stopVibrating();
%                 task.channelRight.normal();
%                 task.channelRight.show();
%             end

            task.photobox.off();

            task.dc.log('Go Cue');
        end

        function moveOnset(task, ~)
            task.dc.log('Move Onset');
        end

%         function targetShift(task, data)
%             task.dc.log('Target Shift');
%             C = data.C;
%             P = data.P;
%
%             if strcmpi(C.targetNamePostShift, 'Left')
%                 task.target.dim(P.inactiveTargetContrast);
%                 task.targetLeft.undim();
%                 task.targetActive = task.targetLeft;
%             else
%                 task.target.dim(P.inactiveTargetContrast);
%                 task.targetRight.undim();
%                 task.targetActive = task.targetRight;
%             end
%
%             %task.target.shift(C.targetXPostShift, C.targetYPostShift, ...
%                 %C.targetWidthPostShift, C.targetDepthPostShift);
%         end

%         function TargetJumpR(task, data)
%             task.dc.log('Target Jump R');
%             C = data.C;
% 
% %             if strcmpi(C.targetNamePostShift, 'TargCW')
%                 task.target.hide();
%                 task.targetR.show();
%                 task.targetActive = task.targetR;
% %             end
%         end
% 
%         function TargetJumpL(task, data)
%             task.dc.log('Target Jump L');
%             C = data.C;
% 
% %             if strcmpi(C.targetNamePostShift, 'TargCCW')
%                 task.target.hide();
%                 task.targetL.show();
%                 task.targetActive = task.targetL;
% %             end
%         end


        function targetAcquired(task, ~)
            task.targetActive.acquire();
            task.dc.log('Target Acquired');
        end

        function targetUnacquire(task, ~)
            task.targetActive.unacquire();
            task.dc.log('Target Unacquired');
        end

        function targetSettled(task, data) %#ok<INUSD>
%             P = data.P;
%             trialData = data.trialData;
%             if task.showHold
%                 task.hold.xc = trialData.holdX;
%                 task.hold.yc = trialData.holdY;
%                 task.hold.width = P.holdWindow;
%                 task.hold.height = P.holdWindow;
%                 task.hold.fill = false;
%                 task.hold.show();
%             end
            task.dc.log('Target Settled');
        end

        function targetHeld(task, ~)
            %task.hold.fill = true;
            task.dc.log('Center Held');
        end

        function success(task, data) %#ok<INUSD>
            task.targetActive.success();
%             task.channelLeft.hide();
%             task.channelRight.hide();

            %TD = data.trialData;

            task.sound.playSuccess();
            %rewardToneOff = double(TD.rewardTonePulseInterval - TD.rewardTonePulseLength);
            %task.sound.playTonePulseTrain(TD.rewardTonePulseHz, double(TD.rewardTonePulseLength), ...
            %    rewardToneOff, double(TD.rewardTonePulseReps));

            task.photobox.off();
        end

        function hitObstacle(task, ~)
%             task.channelLeft.collision();
%             task.channelRight.collision();
            if ~task.hitObstacleThisTrial
                % dim target
                %task.target.dim();

                % play failure tone
                %task.sound.playBuzz();
            end

            task.hitObstacleThisTrial = true;
        end

        function releasedObstacle(~, ~)
            return;
%             if ~task.trialFailed
%                 task.channelLeft.normal();
%                 task.channelRight.normal();
%             end
        end

        function failureCenterFlyAway(task, data)
            C = data.C;
            task.trialFailed = true;

            task.center.hide();

            task.target.contour();
            task.target.stopVibrating();
            task.target.flyAway(task.cursor.xc, task.cursor.yc);
%            task.followThoughtarget.flyAway(task.cursor.xc, task.cursor.yc);

%             if C.hasTargetLeft
%                 task.targetLeft.contour();
%                 task.targetLeft.stopVibrating();
%                 task.targetLeft.flyAway(task.cursor.xc, task.cursor.yc);
%             end
%
%             if C.hasTargetRight
%                 task.targetRight.contour();
%                 task.targetRight.stopVibrating();
%                 task.targetRight.flyAway(task.cursor.xc, task.cursor.yc);
%             end

%             if C.hasChannelLeft
%                 task.channelLeft.contour();
%                 task.channelLeft.flyAway(task.cursor.xc, task.cursor.yc);
%             end
%             if C.hasChannelRight
%                 task.channelRight.contour();
%                 task.channelRight.flyAway(task.cursor.xc, task.cursor.yc);
%             end

            task.hold.hide();
            task.sound.playFailure();
            task.photobox.off();
        end

        function failureTargetFlyAway(task, data)
            C = data.C;
            task.trialFailed = true;

            task.center.hide();

            task.target.contour();
            task.target.stopVibrating();
            task.target.flyAway(task.cursor.xc, task.cursor.yc);
%            task.followThoughtarget.flyAway(task.cursor.xc, task.cursor.yc);

%             if C.hasTargetR
%                 task.targetR.contour();
%                 task.targetR.stopVibrating();
%                 task.targetR.flyAway(task.cursor.xc, task.cursor.yc);
%             end
% 
%             if C.hasTargetL
%                 task.targetL.contour();
%                 task.targetL.stopVibrating();
%                 task.targetL.flyAway(task.cursor.xc, task.cursor.yc);
%             end

%             if C.hasTargetLeft
%                 task.targetLeft.contour();
%                 task.targetLeft.stopVibrating();
%                 task.targetLeft.flyAway(task.cursor.xc, task.cursor.yc);
%             end
%
%             if C.hasTargetRight
%                 task.targetRight.contour();
%                 task.targetRight.stopVibrating();
%                 task.targetRight.flyAway(task.cursor.xc, task.cursor.yc);
%             end

%             if C.hasChannelLeft
%                 task.channelLeft.contour();
%                 task.channelLeft.flyAway(task.cursor.xc, task.cursor.yc);
%             end
%             if C.hasChannelRight
%                 task.channelRight.contour();
%                 task.channelRight.flyAway(task.cursor.xc, task.cursor.yc);
%             end

            task.hold.hide();
            task.sound.playFailure();
            task.photobox.off();
        end

        function failureHitObstacle(task, data)
            C = data.C;
            task.trialFailed = true;

            task.target.flyAway(task.cursor.xc, task.cursor.yc);
%            task.followThoughtarget.flyAway(task.cursor.xc, task.cursor.yc);

% 
%             if C.hasTargetR
%                 task.targetR.flyAway(task.cursor.xc, task.cursor.yc);
%             end
%             if C.hasTargetL
%                 task.targetL.flyAway(task.cursor.xc, task.cursor.yc);
%             end
%             if C.hasTargetLeft
%                 task.targetLeft.flyAway(task.cursor.xc, task.cursor.yc);
%             end
%             if C.hasTargetRight
%                 task.targetRight.flyAway(task.cursor.xc, task.cursor.yc);
%             end
%             if C.hasChannelLeft
%                 task.channelLeft.collision();
%             end
%             if C.hasChannelRight
%                 task.channelRight.collision();
%             end

            task.hold.hide();
            task.sound.playFailure();
            task.photobox.off();
        end

        function iti(task, ~)
            task.center.hide();
            task.hold.hide();
            task.target.hide();
%             task.targetR.hide();
%             task.targetL.hide();
%            task.followThoughtarget.hide();

%             task.targetLeft.hide();
%             task.targetRight.hide();
%             task.channelLeft.hide();
%             task.channelRight.hide();
            task.photobox.off();
        end
    end
end
