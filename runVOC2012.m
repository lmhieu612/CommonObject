function[] = runVOC2012(cls,K,distance)

addpath('auxiliaries');
addpath('pgp_clustering');
%addpath(genpath('objectness-release-v2.2'));
warning('off');

option.dataset = 'trainval';
option.clsi =cls;

option.sm =0;
option.data = 'VOC2012';
option.devkit ='VOCdevkit';
kkkkk=pwd;
cd(fullfile('..','dataset',option.devkit));
addpath(fullfile('VOCcode'));VOCinit;
cd(kkkkk);
option.cls = VOCopts.classes{option.clsi};
option.imlistpath = fullfile(option.data,option.dataset,'imlist',option.cls); load(fullfile(option.imlistpath,'imlist.mat'));
if option.sm
    k= [recs_class(:).segmented];
    k = find(k==true);
    option.imn = k(option.imn);
end
option.nfilter = 512;
option.recs_class = recs_class;
option.VOCopts = VOCopts;
option.nim = length(recs_class);
option.bdE =1;      % Boundary weight
option.layer = 36;
option.show =0;
option.saveflag = true;
option.CNNrespath =fullfile(option.data,'trainval','CNNres');
option.netmeta = 'netmeta.mat';
option.sppath = fullfile(option.data,'sp','%s_%d.mat');
option.prop_w =0.2; %0.2 is good for Be 1 % was testing with 1
option.threshold = 0.3;
option.smooththreshold = 0.01;
option.K=K;
 option.aK = K+1;
option.distance = distance;

option.basepath =  fullfile(option.data,option.dataset);
option.respath =  fullfile(option.basepath,'corloc');
mkdir(option.respath);
option.corlocrespath = fullfile(option.respath,'%s_K%d_d%s_th_%0.3f_sth_%0.3f_W%0.1f.mat');
option.resultsfile = sprintf(option.corlocrespath,option.cls,option.K,option.distance,option.threshold,option.smooththreshold,option.prop_w);

clpath = fullfile(option.data,option.dataset,'cluster',option.cls);mkdir(clpath);
option.Kmeansfile = sprintf('%s/%d_%s.mat',clpath,K,option.distance);

%if ~exist(option.resultsfile,'file')
    clear meta windows u_score stats cu_score cn_window windows;
    gen_max(option);
    load(option.Kmeansfile);
    option.maxres = maxres;
  %  IDX = pgpClustering(maxres, 'orig', 0.6);
    option.K = numel(unique(IDX));
    option.aK = option.K +1;
    option.uIDX(:,1) = zeros(1,512);
    for i=1:option.K
        option.uIDX(:,i+1) = [IDX == i];
        if sum(option.uIDX(:,1)) < 30
            option.uIDX(:,1)  = option.uIDX(:,1) + [IDX == i];
        end
        
    end
    parfor imn=1:option.nim
        [ score,nwinds,wds ] = running_funcVOC( option,imn);
        cu_score{imn} =  score;
        cn_window{imn} =  nwinds;
        windows{imn} = wds;
        %pause;
    end;
    u_score=vertcat(cu_score{:});
    n_window = vertcat(cn_window{:});
    stats.corloc = sum(u_score>=0.5) / option.nim;
    stats.nwindows  = mean(n_window)
 %   save(option.resultsfile,'u_score','windows','n_window','stats');
%end

