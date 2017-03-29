function [AnatomicalFile, FunctionalFiles, slices, TRsPerScan, oppPE, StimFiles] = getRetinotopyScanInfo(subjDate)


switch subjDate
    case  'AWOct27'
        
        AnatomicalFile = 'BVIS_999_WIP_MPRAGE_nobodytune_SENSE_2_1';
        FunctionalFiles = {'BVIS_999_WIP_120Dyn_3x3x3(0.5)_SENSE_5_1',...
            'BVIS_999_WIP_120Dyn_3x3x3(0.5)_SENSE_6_1',...
            'BVIS_999_WIP_120Dyn_3x3x3(0.5)_SENSE_7_1',...
            'BVIS_999_WIP_120Dyn_3x3x3(0.5)_SENSE_8_1',...
            'BVIS_999_WIP_120Dyn_3x3x3(0.5)_SENSE_9_1',...
            'BVIS_999_WIP_120Dyn_3x3x3(0.5)_SENSE_10_1'};
        
        TRsPerScan = 120;
        slices = 30;
        
        oppPE = '';  %opposite-phase encoded scan
        
        StimFiles = {'AW_151027_01_Rings.mat', ...
            'AW_151027_02_Wedges.mat',...
            'AW_151027_03_Meridians.mat',...
            'AW_151027_04_Rings.mat', ...
            'AW_151027_05_Wedges.mat',...
            'AW_151027_06_Meridians.mat'};
        
    case 'JMNov30'
        
        AnatomicalFile = 'BVIS_002_WIP_MPRAGE_nobodytune_SENSE_2_1';
        FunctionalFiles = {'BVIS_002_WIP_128Dyn_3x3x3(0.5)_SENSE_4_1',...
            'BVIS_002_WIP_128Dyn_3x3x3(0.5)_SENSE_5_1',...
            'BVIS_002_WIP_128Dyn_3x3x3(0.5)_SENSE_6_1',...
            'BVIS_002_WIP_128Dyn_3x3x3(0.5)_SENSE_7_1',...
            'BVIS_002_WIP_128Dyn_3x3x3(0.5)_SENSE_8_1',...
            'BVIS_002_WIP_128Dyn_3x3x3(0.5)_SENSE_9_1'};
        
        % number of TRs per scan:
        TRsPerScan =128;
        slices = 30;

        StimFiles = {'JM_151130_01_Rings.mat', ...
            'JM_151130_02_Wedges.mat',...
            'JM_151130_03_Meridians.mat',...
            'JM_151130_04_Rings.mat', ...
            'JM_151130_05_Wedges.mat',...
            'JM_151130_06_Meridians.mat'};
        
        oppPE = 'BVIS_002_WIP_1Dyn_FSDIR_A3x3x3(0.5)_SENSE_3_1';  %opposite-phase encoded scan
        
    case 'JSFeb04'
        
        AnatomicalFile = 'BVIS_003_WIP_MPRAGE_nobodytune_SENSE_2_1';
        FunctionalFiles = {'BVIS_003_WIP_128Dyn_3x3x3(0.5)_SENSE_4_1',...
            'BVIS_003_WIP_128Dyn_3x3x3(0.5)_SENSE_5_1',...
            'BVIS_003_WIP_128Dyn_3x3x3(0.5)_SENSE_10_1',... %the very last scan was a Meridians scan to replace the 3rd scan, because he fell asleep
            'BVIS_003_WIP_128Dyn_3x3x3(0.5)_SENSE_7_1',...
            'BVIS_003_WIP_128Dyn_3x3x3(0.5)_SENSE_8_1',...
            'BVIS_003_WIP_128Dyn_3x3x3(0.5)_SENSE_9_1'};
        
        % number of TRs per scan:
        TRsPerScan =128;
        slices = 30;

        StimFiles = {'JS_160204_01_Rings.mat', ...
            'JS_160204_02_Wedges.mat',...
            'JS_160204_07_Meridians.mat',...
            'JS_160204_04_Rings.mat', ...
            'JS_160204_05_Wedges.mat',...
            'JS_160204_06_Meridians.mat'};
        
        oppPE = 'BVIS_003_WIP_1Dyn_FSDIR_A3x3x3(0.5)_SENSE_3_1';  %opposite-phase encoded scan
        
    case 'KBApr25'
        
        AnatomicalFile = 'BVIS_006_WIP_MPRAGE_nobodytune_SENSE_2_1';
        FunctionalFiles = {'BVIS_006_WIP_128Dyn_3x3x3(0.5)_SENSE_4_1',...
            'BVIS_006_WIP_128Dyn_3x3x3(0.5)_SENSE_5_1',...
            'BVIS_006_WIP_128Dyn_3x3x3(0.5)_SENSE_6_1',...
            'BVIS_006_WIP_128Dyn_3x3x3(0.5)_SENSE_7_1',...
            'BVIS_006_WIP_128Dyn_3x3x3(0.5)_SENSE_8_1',...
            'BVIS_006_WIP_128Dyn_3x3x3(0.5)_SENSE_9_1'};
        
        % number of TRs per scan:
        TRsPerScan =128;
        slices = 30;

        StimFiles = {'KB_160425_01_Rings.mat', ...
            'KB_160425_02_Wedges.mat',...
            'KB_160425_03_Meridians.mat',...
            'KB_160425_04_Rings.mat', ...
            'KB_160425_05_Wedges.mat',...
            'KB_160425_06_Meridians.mat'};
        
        oppPE = 'BVIS_006_WIP_1Dyn_FSDIR_A3x3x3(0.5)_SENSE_3_1';  %opposite-phase encoded scan
        
    case 'DPMay05'
        
        AnatomicalFile = 'BVIS_007_WIP_MPRAGE_nobodytune_SENSE_2_1';
        FunctionalFiles = {'BVIS_007_WIP_128Dyn_3x3x3(0.5)_SENSE_4_1',...
            'BVIS_007_WIP_128Dyn_3x3x3(0.5)_SENSE_5_1',...
            'BVIS_007_WIP_128Dyn_3x3x3(0.5)_SENSE_6_1',...
            'BVIS_007_WIP_128Dyn_3x3x3(0.5)_SENSE_7_1',...
            'BVIS_007_WIP_128Dyn_3x3x3(0.5)_SENSE_8_1',...
            'BVIS_007_WIP_128Dyn_3x3x3(0.5)_SENSE_9_1'};
        
        % number of TRs per scan:
        TRsPerScan =128;
        slices = 30;

        StimFiles = {'DP_160505_01_Rings.mat', ...
            'DP_160505_02_Wedges.mat',...
            'DP_160505_03_Meridians.mat',...
            'DP_160505_04_Rings.mat', ...
            'DP_160505_05_Wedges.mat',...
            'DP_160505_06_Meridians.mat'};
        
        oppPE = 'BVIS_007_WIP_1Dyn_FSDIR_A3x3x3(0.5)_SENSE_3_1';  %opposite-phase encoded scan
        
    case 'MKJan09'
        
        AnatomicalFile = 'BVIS_008_WIP_MPRAGE_nobodytune_SENSE_2_1';
        FunctionalFiles = {'BVIS_008_WIP_128Dyn_3x3x3(0.5)_SENSE_4_1',...
            'BVIS_008_WIP_128Dyn_3x3x3(0.5)_SENSE_5_1',...
            'BVIS_008_WIP_128Dyn_3x3x3(0.5)_SENSE_6_1',...
            'BVIS_008_WIP_128Dyn_3x3x3(0.5)_SENSE_7_1',...
            'BVIS_008_WIP_128Dyn_3x3x3(0.5)_SENSE_8_1',...
            'BVIS_008_WIP_128Dyn_3x3x3(0.5)_SENSE_9_1'};
        
        % number of TRs per scan:
        TRsPerScan =128;
        slices = 30;

        StimFiles = {'MK_170109_01_Rings.mat', ...
            'MK_170109_02_Wedges.mat',...
            'MK_170109_03_Meridians.mat',...
            'MK_170109_04_Rings.mat', ...
            'MK_170109_05_Wedges.mat',...
            'MK_170109_06_Meridians.mat'};
        
        oppPE = 'BVIS_008_WIP_1Dyn_FSDIR_A3x3x3(0.5)_SENSE_3_1';  %opposite-phase encoded scan
        
    case 'AWJan26'
        
        AnatomicalFile = 'BVIS_999_26JAN17_WIP_MPRAGE_nobodytune_SENSE_2_1';
        FunctionalFiles = {'BVIS_999_26JAN17_WIP_128Dyn_3x3x3(0.5)_SENSE_4_1',...
            'BVIS_999_26JAN17_WIP_128Dyn_3x3x3(0.5)_SENSE_5_1',...
            'BVIS_999_26JAN17_WIP_128Dyn_3x3x3(0.5)_SENSE_6_1',...
            'BVIS_999_26JAN17_WIP_128Dyn_3x3x3(0.5)_SENSE_7_1',...
            'BVIS_999_26JAN17_WIP_128Dyn_3x3x3(0.5)_SENSE_8_1',...
            'BVIS_999_26JAN17_WIP_128Dyn_3x3x3(0.5)_SENSE_9_1',...
            'BVIS_999_26JAN17_WIP_128Dyn_3x3x3(0.5)_SENSE_10_1'};
        
        oppPE = 'BVIS_999_26JAN17_WIP_1Dyn_FSDIR_A3x3x3(0.5)_SENSE_3_1';  %opposite-phase encoded scan
        
        % number of TRs per scan:
        TRsPerScan =128;
        slices = 35;

        StimFiles = {'AW_170126_01_Rings.mat', ...
            'AW_170126_02_Wedges.mat',...
            'AW_170126_03_Meridians.mat',...
            'AW_170126_04_Rings.mat', ...
            'AW_170126_05_Wedges.mat',...
            'AW_170126_06_Meridians.mat',...
            'AW_170126_07_Wedges.mat'};
        
    case 'AWJan26ToOct27Anat'
        
        AnatomicalFile = 'BVIS_999_WIP_MPRAGE_nobodytune_SENSE_2_1.PAR';
        FunctionalFiles = {'BVIS_999_26JAN17_WIP_128Dyn_3x3x3(0.5)_SENSE_4_1',...
            'BVIS_999_26JAN17_WIP_128Dyn_3x3x3(0.5)_SENSE_5_1',...
            'BVIS_999_26JAN17_WIP_128Dyn_3x3x3(0.5)_SENSE_6_1',...
            'BVIS_999_26JAN17_WIP_128Dyn_3x3x3(0.5)_SENSE_7_1',...
            'BVIS_999_26JAN17_WIP_128Dyn_3x3x3(0.5)_SENSE_8_1',...
            'BVIS_999_26JAN17_WIP_128Dyn_3x3x3(0.5)_SENSE_9_1',...
            'BVIS_999_26JAN17_WIP_128Dyn_3x3x3(0.5)_SENSE_10_1'};
        
        oppPE = 'BVIS_999_26JAN17_WIP_1Dyn_FSDIR_A3x3x3(0.5)_SENSE_3_1';  %opposite-phase encoded scan
        
        % number of TRs per scan:
        TRsPerScan =128;
        slices = 35;

        StimFiles = {'AW_170126_01_Rings.mat', ...
            'AW_170126_02_Wedges.mat',...
            'AW_170126_03_Meridians.mat',...
            'AW_170126_04_Rings.mat', ...
            'AW_170126_05_Wedges.mat',...
            'AW_170126_06_Meridians.mat',...
            'AW_170126_07_Wedges.mat'};
        
    case 'AGJan27'
        
        AnatomicalFile = 'BVIS_009_WIP_MPRAGE_nobodytune_SENSE_2_1';
        FunctionalFiles = {'BVIS_009_WIP_128Dyn_3x3x3(0.5)_SENSE_4_1',...
            'BVIS_009_WIP_128Dyn_3x3x3(0.5)_SENSE_5_1',...
            'BVIS_009_WIP_128Dyn_3x3x3(0.5)_SENSE_6_1',...
            'BVIS_009_WIP_128Dyn_3x3x3(0.5)_SENSE_7_1',...
            'BVIS_009_WIP_128Dyn_3x3x3(0.5)_SENSE_8_1',...
            'BVIS_009_WIP_128Dyn_3x3x3(0.5)_SENSE_9_1',...
            'BVIS_009_WIP_128Dyn_3x3x3(0.5)_SENSE_10_1'};
        
        oppPE = 'BVIS_009_WIP_1Dyn_FSDIR_A3x3x3(0.5)_SENSE_3_1';  %opposite-phase encoded scan
        
        % number of TRs per scan:
        TRsPerScan =128;
        slices = 35;

        StimFiles = {'AG_170127_01_Rings.mat', ...
            'AG_170127_02_Wedges.mat',...
            'AG_170127_03_Meridians.mat',...
            'AG_170127_04_Rings.mat', ...
            'AG_170127_05_Wedges.mat',...
            'AG_170127_06_Meridians.mat',...
            'AG_170127_07_Wedges.mat'};
        
      case 'EMFeb10'
        
        AnatomicalFile = 'BVIS_010_WIP_MPRAGE_nobodytune_SENSE_2_1';
        FunctionalFiles = {'BVIS_010_WIP_128Dyn_3x3x3(0.5)_SENSE_4_1',...
            'BVIS_010_WIP_128Dyn_3x3x3(0.5)_SENSE_5_1',...
            'BVIS_010_WIP_128Dyn_3x3x3(0.5)_SENSE_6_1',...
            'BVIS_010_WIP_128Dyn_3x3x3(0.5)_SENSE_7_1',...
            'BVIS_010_WIP_128Dyn_3x3x3(0.5)_SENSE_8_1',...
            'BVIS_010_WIP_128Dyn_3x3x3(0.5)_SENSE_9_1',...
            'BVIS_010_WIP_128Dyn_3x3x3(0.5)_SENSE_10_1'};
        
        oppPE = 'BVIS_010_WIP_1Dyn_FSDIR_A3x3x3(0.5)_SENSE_3_1';  %opposite-phase encoded scan
        
        % number of TRs per scan:
        TRsPerScan =128;
        slices = 35;

        StimFiles = {'EM_170210_01_Rings.mat', ...
            'EM_170210_02_Wedges.mat',...
            'EM_170210_03_Meridians.mat',...
            'EM_170210_04_Rings.mat', ...
            'EM_170210_05_Wedges.mat',...
            'EM_170210_06_Meridians.mat',...
            'EM_170210_07_Wedges.mat'};
        
        
        case 'GDMar17'
        
        AnatomicalFile = 'BVIS_011_WIP_MPRAGE_nobodytune_SENSE_2_1';
        FunctionalFiles = {'BVIS_011_WIP_128Dyn_3x3x3(0.5)_SENSE_4_1';...
                           'BVIS_011_WIP_128Dyn_3x3x3(0.5)_SENSE_5_1';...
                           'BVIS_011_WIP_128Dyn_3x3x3(0.5)_SENSE_6_1';...
                           'BVIS_011_WIP_128Dyn_3x3x3(0.5)_SENSE_7_1';...
                           'BVIS_011_WIP_128Dyn_3x3x3(0.5)_SENSE_8_1';...
                           'BVIS_011_WIP_128Dyn_3x3x3(0.5)_SENSE_9_1';...
                           'BVIS_011_WIP_106Dyn_3x3x3(0.5)_SENSE_10_1';...
                           'BVIS_011_WIP_106Dyn_3x3x3(0.5)_SENSE_11_1';...
                           'BVIS_011_WIP_102Dyn_3x3x3(0.5)_SENSE_12_1'};
        
        oppPE = 'BVIS_011_WIP_1Dyn_FSDIR_A3x3x3(0.5)_SENSE_3_1';  %opposite-phase encoded scan
        
        % number of TRs per scan:
        TRsPerScan = [128 128 128 128 128 128 106 106 102];
        slices = 30; %this one accidentally used the old exam card 

        %stim files list includes PRT files for the 2 fLoc scans, and mat
        %file for the 1 VWFA_Attn2 localizer scan 
        StimFiles = {'GD_170317_01_Rings.mat'; ...
                     'GD_170317_02_Wedges.mat';...
                     'GD_170317_03_Meridians.mat';...
                     'GD_170317_04_Rings.mat'; ...
                     'GD_170317_05_Wedges.mat';...
                     'GD_170317_06_Meridians.mat';...
                     'fLoc_oddball_GD_17-Mar-2017_01_run_1.prt';...
                     'fLoc_oddball_GD_17-Mar-2017_02_run_1.prt';...
                     'GD_170317_Loclzr_01.mat'};
        
    case 'DSMar22'
        
        AnatomicalFile = 'BVIS_012_WIP_MPRAGE_nobodytune_SENSE_2_1';
        FunctionalFiles = {'BVIS_012_WIP_128Dyn_3x3x3(0.5)_SENSE_4_1';...
                           'BVIS_012_WIP_128Dyn_3x3x3(0.5)_SENSE_5_1';...
                           'BVIS_012_WIP_128Dyn_3x3x3(0.5)_SENSE_6_1';...
                           'BVIS_012_WIP_128Dyn_3x3x3(0.5)_SENSE_7_1';...
                           'BVIS_012_WIP_128Dyn_3x3x3(0.5)_SENSE_8_1';...
                           'BVIS_012_WIP_128Dyn_3x3x3(0.5)_SENSE_9_1';...
                           'BVIS_012_WIP_106Dyn_3x3x3(0.5)_SENSE_10_1';...
                           'BVIS_012_WIP_106Dyn_3x3x3(0.5)_SENSE_11_1';...
                           'BVIS_012_WIP_102Dyn_3x3x3(0.5)_SENSE_12_1';...
                           'BVIS_012_WIP_102Dyn_3x3x3(0.5)_SENSE_13_1'};
        
        oppPE = 'BVIS_012_WIP_1Dyn_FSDIR_A3x3x3(0.5)_SENSE_3_1';  %opposite-phase encoded scan
        
        % number of TRs per scan:
        TRsPerScan = [128 128 128 128 128 128 106 106 102 102];
        slices = 35; %newer exam card 

        %stim files list includes PRT files for the 2 fLoc scans, and mat
        %file for the 1 VWFA_Attn2 localizer scan 
        StimFiles = {'DS_170322_01_Rings.mat'; ...
                     'DS_170322_02_Wedges.mat';...
                     'DS_170322_03_Meridians.mat';...
                     'DS_170322_04_Rings.mat'; ...
                     'DS_170322_05_Wedges.mat';...
                     'DS_170322_06_Meridians.mat';...
                     'fLoc_oddball_DS_22-Mar-2017_01_run_1.prt';...
                     'fLoc_oddball_DS_22-Mar-2017_02_run_1.prt';...
                     'DS_170322_Loclzr_01.mat';...
                     'DS_170322_Loclzr_02.mat'};
end