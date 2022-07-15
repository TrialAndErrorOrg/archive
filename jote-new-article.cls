%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% jote-article.cls, v2.0, 2021/05/03
% This work is adapted from a template, which was originally developed by Overleaf in partnership with Wiley and published under the Creative Commons 4.0 BY license.
%
% This work is licensed under the GNU General Public License 3.0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{jote-new-article}[2022/03/01, v2.0]


%% Definitions for adding journal elements
\def\@jotetitle{}

\def\@jlogo{}
\def\@jname{}
\def\@jyear{}
\def\@jpages{}
\def\@jvolume{}
\def\@jissue{}
\def\@jwebsite{}

\def\@pubpub{}
\def\@companiondoi{}
\def\@companiontitle{}
\def\@companionauthor{}
\def\@companionyear{}
\def\@companionabstract{}
\def\@companionkey{}
\def\@abstracttext{}

\def\@runningauthor{}
\def\@corraddress{}
\def\@corremail{}
\def\@fundinginfo{}
\def\@presentaddress{}

\def\@rgainfo{}

\def\@papertype{}
\def\@paperfield{}
\def\@paperdoi{}
\def\@paperreceived{}
\def\@paperrevised{}
\def\@paperaccepted{}
\def\@paperpublished{}
\def\@paperpublisheddate{}
\def\@paperissued{}
\def\@papereditor{}

\def\@rolling{}
\def\@subtitle{}

\def\@heightabstract{}
\def\@widthaffil{}

\def\@noabstract{}

\def\@funding{}
\def\@acknowledgments{}
\def\@contributions{}
\def\@interests{}
\def\@keywordsabstract{}

\def\@authorone{}
\def\@authortwo{}
\def\@authorthree{}
\def\@authorfour{}
\def\@authorfive{}
\def\@orcidicon{}

%for peer review
\def\@ogauthor{}
\def\@prround{}

\def\jote@articletype{}

\newif\if@numeric
\newif\if@authordate
\newif\if@amsrefs
\newif\if@blindreview
\newif\if@useserif
\newif\if@jote@lineno

\newif\if@seplic

\newif\if@reflection
\newif\if@rga
\newif\if@empirical
\newif\if@meta
\newif\if@editorial
\newif\if@review

\newif\if@issue
\newif\if@rolling
\newif\if@header
\newif\if@noabstract

\newif\if@twocolumn
%% Add options for other journals here
\DeclareOption{jote}{%
  \def\@jlogo{jabr-logo}%
  \def\@jname{J Appl Behav Res}%
  \def\@jwebsite{joteonlinelibrary.com/journal/jabr}%
}


%% Options for bibliography style
\DeclareOption{numeric}{
  \@numerictrue
  \@authordatefalse
  \@amsrefsfalse
}
\DeclareOption{authordate}{
  \@numericfalse
  \@authordatetrue
  \@amsrefsfalse
}
\DeclareOption{ams-refs}{
  \@numericfalse
  \@authordatefalse
  \@amsrefstrue
}

\DeclareOption{seplic}{
    \@seplictrue
}

%% Options for papertype

\DeclareOption{reflection}{\@reflectiontrue \@reviewfalse \renewcommand\jote@articletype{Reflection}}
\DeclareOption{rga}{\@rgatrue \@reviewfalse \renewcommand\jote@articletype{Rejected Grant Application}}
\DeclareOption{empirical}{\@empiricaltrue \@reviewfalse \renewcommand\jote@articletype{Empirical}}
\DeclareOption{meta}{\@metatrue \@reviewfalse \renewcommand\jote@articletype{Meta-Research}}
\DeclareOption{editorial}{\@editorialtrue \@reviewfalse \renewcommand\jote@articletype{Editorial}}
\DeclareOption{review}{\@reviewtrue \renewcommand\jote@articletype{Peer Review}}

\DeclareOption{issue}{\@issuetrue \@rollingfalse}
\DeclareOption{header}{\@headertrue}
\DeclareOption{noabstract}{\@noabstracttrue}
%% Option for blind review
\DeclareOption{blind}{\@blindreviewtrue}

%% v1.3: Option for serif fonts
\DeclareOption{serif}{\@useseriftrue}

%% v1.4: Option for line numbers
\DeclareOption{lineno}{\@jote@linenotrue}

%%

%% v1.2: don't set any defaults
% \ExecuteOptions{num-refs}
\ProcessOptions\relax


\LoadClass[english,twocolumn,9pt]{extarticle}

\RequirePackage{scrextend}
\RequirePackage{trace}
\RequirePackage{fontspec}
\RequirePackage{booktabs} %Makes tables "prettier"
\RequirePackage[table]{xcolor}
\RequirePackage{mathtools}
\RequirePackage{bm}
\RequirePackage{graphicx}
\RequirePackage{tabularx}
\RequirePackage{textcase}
\RequirePackage{dashrule}
\RequirePackage{ragged2e}
\RequirePackage{authblk}
\RequirePackage[hyphens]{url}
\RequirePackage{soul}
\RequirePackage{xpatch}
\RequirePackage{afterpage}
\RequirePackage{hyperref} %For bookmarks and links
\RequirePackage{paracol} % necessary to make reviewbox pagebreak work
%\RequirePackage{cooltooltips} % For hover and comments
%\RequirePackage[inactive]{fancytooltips} %  allows inclusion of tooltips which contain arbitrary TEX material
\RequirePackage{pdfcomment} % little bit less complex hover
\RequirePackage{tikz,lipsum,lmodern}
\RequirePackage[breakable,skins,most]{tcolorbox}
\RequirePackage{float}%to define custom environments that float

\RequirePackage{placeins}

% \RequirePackage{flushend} % Balances two columns at the end of the page

%%% LaTeX3 packages
\RequirePackage{xcoffins} %to do complicated aligning

\RequirePackage{etex} %for /dimexpr etc
\tcbuselibrary{skins,xparse,breakable}
%\RequirePackage[backend = biber, style=apa]{biblatex}


%%%%%%%%%%%%%%%
%% Colors
%%%%%%%%%%%%%%%





\definecolor{joteorange}{HTML}{FEAF0C}
\definecolor{jotedark}{HTML}{002642}
\colorlet{tip}{jotedark}
\definecolor{joteOrangeLight}{HTML}{fbeacd}
\colorlet{lightblack}{jotedark!70}
\colorlet{betterlightblack}{lightblack!65!gray!65}
\colorlet{darklightblack}{lightblack!65!gray!85}

\definecolor{orcidlogocol}{HTML}{a6ce39}

%\if@twocolumn
%\else
%  \RequirePackage[right]{lineno}
%\fi


%%%%%%%%%%%%%%%%%%
%% Lengths
%%%%%%%%%%%%%%%%%

\newlength{\smallwidth} % width of o.a. the columnsep
\setlength{\smallwidth}{\baselineskip}

\RequirePackage
 [paperwidth=210mm,paperheight=280mm,
  textwidth=130mm,
%  lines=50,
  textheight=230mm,
  headsep=2\smallwidth,headheight=20pt,
  footskip=\smallwidth,
  columnsep=\smallwidth,
  includeheadfoot, inner= 4.8cm,
  outer=15mm, bindingoffset=0mm, marginparwidth=2.5cm, marginparsep=2\smallwidth
  %margin=5cm,
  ]
{geometry}

\RequirePackage{alphalph}
\newalphalph{\fnsymbolmult}[mult]{\@fnsymbol}{5}
\RequirePackage{lettrine}

\newcounter{authorfn}
\setcounter{authorfn}{1}
\newcommand{\authfn}[1]{%
  \fnsymbolmult{#1}%
}

% \newcommand{\presentadd}[2][]{
%   \appto{\@presentaddress}{%
%   \ifx\empty#1\else\textsuperscript{#1}\fi
%   #2%
%   }{}{}
% }

\newcommand{\jotetitle}[1]{\def\@jotetitle{#1}}

\newcommand{\jlogo}[1]{\def\@jlogo{#1}}
\newcommand{\jname}[1]{\def\@jname{#1}}
\newcommand{\jyear}[1]{\def\@jyear{#1}}
\newcommand{\jvolume}[1]{\def\@jvolume{#1}}
\newcommand{\jissue}[1]{\def\@jissue{#1}}
\newcommand{\jpages}[1]{\def\@jpages{#1}}
\newcommand{\jwebsite}[1]{\def\@jwebsite{#1}}

%JOTE specific commands: pubpub link, link to article on PubPub, Title of the companion piece and Abstract of the companion Piece
\newcommand{\pubpub}[1]{\def\@pubpub{#1}}
\newcommand{\companionurl}[1]{\def\@companionurl{#1}}
\newcommand{\companiontitle}[1]{\def\@companiontitle{#1}}
\newcommand{\companionyear}[1]{\def\@companionyear{#1}}
\newcommand{\companionauthor}[1]{\def\@companionauthor{#1}}
\newcommand{\companionabstract}[1]{\def\@companionabstract{#1}}
\newcommand{\companionkey}[1]{\def\@companionkey{#1}}
\newcommand{\abstracttext}[1]{\def\@abstracttext{#1}}

\newcommand{\heightabstract}[1]{\def\@heightabstract{#1}}
\newcommand{\widthaffil}[1]{\def\@widthaffil{#1}}

%Command that appends rolling to the Title if non-empty.
\newcommand{\rolling}[1]{\def\@rolling{#1}}
%Command for the subtitle, if any
\newcommand{\subtitle}[1]{\def\@subtitle{#1}}


\newcommand{\runningauthor}[1]{\def\@runningauthor{#1}}
\newcommand{\corraddress}[1]{\def\@corraddress{#1}}
\newcommand{\corremail}[1]{\def\@corremail{#1}}

\newcommand{\rgainfo}[1]{\def\@rgainfo{#1}}

\newcommand{\fundinginfo}[1]{\def\@fundinginfo{#1}}

\newcommand{\paperdoi}[1]{\def\@paperdoi{#1}}
\newcommand{\paperreceived}[1]{\def\@paperreceived{#1}}
\newcommand{\paperrevised}[1]{\def\@paperrevised{#1}}
\newcommand{\paperaccepted}[1]{\def\@paperaccepted{#1}}

\newcommand{\paperpublished}[1]{\def\@paperpublished{#1}}
\newcommand{\paperpublisheddate}[1]{\def\@paperpublisheddate{#1}}
\newcommand{\paperissued}[1]{\def\@paperissued{#1}}
\newcommand{\papereditor}[1]{\def\@papereditor{#1}}
\newcommand{\papertype}[1]{\def\@papertype{#1}}
\newcommand{\paperfield}[1]{\def\@paperfield{#1}}

\newcommand{\funding}[1]{\def\@funding{#1}}
\newcommand{\acknowledgments}[1]{\def\@acknowledgments{#1}}
\newcommand{\contributions}[1]{\def\@contributions{#1}}
\newcommand{\interests}[1]{\def\@interests{#1}}

\newcommand{\keywordsabstract}[1]{\def\@keywordsabstract{#1}}
\newcommand{\noabstract}[1]{\def\@noabstract{#1}}
%Author metadata
\newcommand{\authorone}[1]{\def\@authorone{#1}}
\newcommand{\authortwo}[1]{\def\@authortwo{#1}}
\newcommand{\authorthree}[1]{\def\@authorthree{#1}}
\newcommand{\authorfour}[1]{\def\@authorfour{#1}}
\newcommand{\authorfive}[1]{\def\@authorfive{#1}}
%for peer review
\newcommand{\ogauthor}[1]{\def\@ogauthor{#1}}
\newcommand{\prround}[1]{\def\@prround{#1}}

% spacing command
\newcommand{\bigspace}{3\baselineskip}

\RequirePackage{amssymb}
\RequirePackage{unicode-math}
\RequirePackage{firamath-otf}

%%%%%%%%%%%%%%%%%%
%% Fonts
%%%%%%%%%%%%%%%%%%


\setmainfont{OpenSans}[
    Extension={.ttf},
    Path={../../../fonts/OpenSans/},
    UprightFont={*-Light},
    ItalicFont={*-LightItalic},
    BoldFont={*-SemiBold},
]


%\setmathfont{OpenSans)[
%    Extension={.ttf},
%    Path={../../../fonts/OpenSans/},
%    UprightFont={*-Light},
%    ItalicFont={*-LightItalic},
%    BoldFont={*-Medium},
%]

\newfontfamily\openreg{OpenSans}[
    Extension={.ttf},
    Path={../../../fonts/OpenSans/},
    UprightFont={*-Regular},
    ItalicFont={*-Italic},
    BoldFont={*-Bold},
]


\newfontfamily\overpass{Overpass}[
  Path = {../../../},
    Extension = .ttf,
   UprightFont = *-Regular,
   BoldFont = *-SemiBold,
]

\newfontfamily\overpasslight{Overpass}[
  Path = ../../../,
    Extension = .ttf,
   UprightFont = *-Light,
   BoldFont = *-Regular
]

%[
%    Path={./},
%    Extension={.ttf},
%    BoldFont={*-SemiBold.ttf},
%    UprightFont={*-Regular.ttf},
%]

%\newfontfamily\openreg{
%    [OpenSans-Regular.ttf]
%}
%\RequirePackage[default]{cabin}
%\RequirePackage[default]{opensans}
%\renewcommand*\familydefault{\sfdefault}
%

%%%%%%% Fontsizes
%\newcommand\normline{12pt}
%\newcommand\normsize{9pt}

% Makes everything look waaayyyy better, just try turning it off and on again
\RequirePackage{microtype}


%lin in front of section
\newcommand\jotebar{{\color{joteorange}\kern1pt\rule[-0.31\dp\strutbox]{1.2pt}{0.7\baselineskip}\kern1pt}}





\RequirePackage{fontawesome5}
\RequirePackage{academicons}
\newcommand{\orcid}[1]{ \href{orcid.org/#1}{{\color{orcidlogocol}{\kern-0.2em \aiOrcid \kern-0.2em}}} }
% Accompanying article box
%
%
%


\newtcolorbox{companionbox}{%
    enhanced, 
    top=\dimexpr.8\smallwidth,
    bottom=\dimexpr 1.6\smallwidth, 
    left=1.7\smallwidth, 
    right=1.7\smallwidth, 
    colframe=joteOrangeLight,
    colbacktitle=joteOrangeLight,
    colback=joteOrangeLight, 
    coltitle=jotedark,
    fontupper={\openreg \color{jotedark}},
    fonttitle={\overpass \bfseries \LARGE \color{jotedark}},
    sharp corners,
    % look if you have a better idea by all means
    % no raisebox doesnt work
    borderline east ={1em}{0pt}{joteorange},
    %title={Companion Article}
}


% Takehome message
\newfloat{takeHomeFloat}{t!}{lop}

\newfloat{originalPurposeFloat}{b!}{lop}

\newtcolorbox{joteBox}[1]{
    enhanced, 
    top=\dimexpr.2\smallwidth,
    bottom=\dimexpr 1.6\smallwidth, 
    left=1.7\smallwidth, 
    right=1.7\smallwidth, 
    colframe=joteOrangeLight,
    colbacktitle=joteOrangeLight,
    colback=joteOrangeLight, 
    coltitle=jotedark,
    fontupper={\openreg \color{jotedark}},
    fonttitle={\overpass \bfseries \LARGE \color{jotedark}},
    sharp corners,
    % look if you have a better idea by all means
    % no raisebox doesnt work
    title={\vskip-.7em #1 \vspace*{.2em}}
}



\newlength{\takeHomeHeight}
\NewEnviron{takeHomeMessage}{
  \begin{takeHomeFloat}
    \phantomsection
    \addcontentsline{toc}{section}{Take-home Message}
        \begin{adjustwidth}{\dimexpr-\fullwidthlen\relax}{-2\smallwidth}
            \begin{minipage}{\dimexpr .5\textwidth + \myoddoffset -\smallwidth\relax}
                 \renewcommand{\baselinestretch}{1.5}
                \begin{joteBox}{Take-home Message}
             % \RaggedRight
                    \small
                    \BODY
                \end{joteBox}
            \end{minipage}
        \end{adjustwidth} 
 % \vskip-.3em
  \end{takeHomeFloat}
}


\NewEnviron{originalPurpose}{%
  \begin{originalPurposeFloat}
    \phantomsection
    \addcontentsline{toc}{section}{Take Home Message}
    \begin{adjustwidth}{\dimexpr-\fullwidthlen\relax}{-2\smallwidth}
        \begin{minipage}{\dimexpr .5\textwidth + \myoddoffset -\smallwidth\relax}
            \renewcommand{\baselinestretch}{1.3}
            \begin{joteBox}{Original Purpose}
                \small
                \BODY
            \end{joteBox}
        \end{minipage}
    \end{adjustwidth} 
  \end{originalPurposeFloat}
}


\newfloat{company}{b!}{lop}

\NewEnviron{companion}{
    \begin{company}%
        \begin{companionbox}%[
            \RaggedRight%
          {\overpass\large\bfseries Companion Article}
          \vskip.5\smallwidth
            \BODY
            %\@companionauthor (\@companionyear), 
            %\@companiontitle
            %\href{https://doi.org/\@paperdoi}{DOI: \@paperdoi}
        \end{companionbox}
    \end{company}
}
\usepackage{changepage}% provides the adjustwidth environment
\usepackage{multicol}% for multiple columns inside the fullwidth environment

% The following code should be used *after* any changes to the margins and
% page layout are made (e.g., after the geometry package has been loaded).
\newlength{\fullwidthlen}
\setlength{\fullwidthlen}{\marginparwidth}
\addtolength{\fullwidthlen}{\marginparsep}

\newenvironment{fullwidth}{%
  \begin{adjustwidth}{-\fullwidthlen}{}%
}{%
  \end{adjustwidth}%
}


% Review boxes
%% Box for review end of doc
\newtcolorbox[auto counter]{reviewend}[1]{%
  breakable,
  width=\textwidth,
  colback=gray!5!white,
  fonttitle=\bfseries,
  title=Reviewer~\thetcbcounter \space #1,
  colframe=gray!25!white,
  coltitle=gray!50!black,
  subtitle style={bottomrule=.5pt,
    toprule=0pt,
    colframe=gray,
    colback=gray!10!white,
    coltext=gray!70!black}
}


%% Box for review at section
\newtcolorbox[auto counter]{reviewat}{%
  enhanced jigsaw,
  breakable,
  pad at break*=1mm,
  width=\linewidth,
  colback=gray!5!white,
  fonttitle=\bfseries,
  title=Peer review,
  colframe=gray!25!white,
  coltitle=gray!50!black,
  subtitle style={bottomrule=.5pt,
    toprule=0pt,
    colback=gray!10!white,
    coltext=gray!70!black}
}

% Peer review hover command
\newcommand{\gotoreview}{\vspace*{-14pt}\hfill%
\pdftooltip{\textcolor{white}{peer reviews}}{click on the arrow to view the peer review comments on this section}%
\hyperref[sec:reviews]{$\bigblacktriangledown$}%
}

% RGA checkbox command
\def\checkmark{\tikz\fill[scale=0.2](.4,.25) -- (.65,0) -- (1,.8) -- (.65,.15) -- cycle;}
\newcommand{\checkedbox}{\rlap{\hspace{.08pt} \checkmark}{$\square$}}

%Set the metadata correctly
\RequirePackage{hyperref}

\AtEndPreamble{
\makeatletter
\hypersetup{
		pdftitle={\@runningauthor\text{ } (\@jyear) - \@title},
    	pdfauthor = {\@authorone%
    	\ifdefempty{\@authortwo}{}{, \@authortwo}%
    	\ifdefempty{\@authorthree}{}{, \@authorthree}%
    	\ifdefempty{\@authorfour}{}{, \@authorfour }%
    	\ifdefempty{\@authorfive}{}{, \@authorfive}}
    	pdfsubject = {\@title},
    	pdfkeywords = {\@keywordsabstract},
        colorlinks=true,
        linkcolor=jotedark,
        filecolor=jotedark,
        urlcolor=jotedark,
        citecolor=jotedark}
\makeatother
}




\RequirePackage{letltxmacro}

%%%% Figures

%% Draw figure aruond boxes
% save the meaning of \includegraphics
%%\AtBeginDocument{
%\LetLtxMacro\latexincludegraphics\includegraphics

% pass the image to \shadowbox
%\renewcommand{\includegraphics}[2][]{%
%  \tcbox{\latexincludegraphics[#1]{#2}}}
%  }


% Formatting of footer for first page
%% v1.4: can't use "real" footnotes anymore for twocolumn
\RequirePackage[flushmargin,bottom,norule, marginal]{footmisc}
\RequirePackage{afterpage}




\def\@fpfootnotes{}
\newcommand{\blfootnote}[1]{\appto{\@fpfootnotes}{#1\par}}


%% Headers
\RequirePackage{fancyhdr}
\fancyhf{}
\renewcommand{\headrule}{}

\newlength{\myoddoffset}
\setlength{\myoddoffset}{\marginparwidth + \marginparsep}

\fancyheadoffset[loh,reh,lof]{\myoddoffset}

\fancyhead[LO]{
  \setlength{\arrayrulewidth}{.5pt}%
  \arrayrulecolor{black}%
%   \if@issue
%   \begin{tabularx}{\dimexpr \textwidth + \marginparwidth + \marginparsep\relax}{@{}l | l  >{\raggedleft\arraybackslash}X @{}}%
%      \thepage &
%                 \raisebox{-0.1em}{\includegraphics[height=1.5\smallwidth]{media/TE_logo_blue@2048px.png}}
%     {\Large\textsc{\lowercase Empirical}}
%     & \if@review {\normalsize Manuscript by\ \ }\fi \@runningauthor
%   \end{tabularx}%
% %
%   \else
  \begin{tabularx}{\dimexpr\textwidth + \marginparwidth + \marginparsep}{@{} l  >{\raggedleft\arraybackslash}X  r @{}}%
    \raisebox{-0.1em}{\includegraphics[height=1.5\smallwidth]{media/TE_logo_blue_high_res.png}} \,
    \Large \color{jotedark} \overpass \jote@articletype
 & \textls[10]{\color{jotedark}\@runningauthor} &  \thepage 
  \end{tabularx}%
  % \fi
}

%not important for now
% \fancyhead[LE]{
%   \setlength{\arrayrulewidth}{.5pt}%
%   \arrayrulecolor{black}%
%   \begin{tabularx}{\textwidth}{@{}l | l l >{\raggedleft\arraybackslash}X @{}}%
%   \thepage & \raisebox{-0.1em}{\includegraphics[height=2\smallwidth]{media/jote_logo_only}} & {\textsc{%
%   \if@empirical Empirical \fi%
%   \if@rga Rejected Grant Application \fi%
%   \if@reflection Reflection \fi%
%   \if@editorial Editorial \fi%
%   \if@meta Meta-Research \fi%
%     \if@review Peer Review\fi%
%   }} & \if@review\begingroup\normalsize Manuscript by\ \  \endgroup\fi\@runningauthor
%   %\multicolumn{1}{@{}c}{} &
%   %\raisebox{0.25em}[0pt][0pt]{\colorbox{white}{\includegraphics[height=2.5em]{media/jote_logo_only}}} &
%   %\quad%
%   %\raisebox{0pt}[0pt][0pt]{\includegraphics[height=2.5em]{./jote-logo}}\\
%   \end{tabularx}%
% }

\fancyfoot[LO]{
  \arrayrulecolor{betterlightblack}%
  \small\selectfont\color{betterlightblack}%
  \begin{tabularx}{\dimexpr \textwidth + \myoddoffset }{@{}X  r @{}}%
  \hline
  & \\
  \overpasslight
  \@jname, \if@issue \textbf{\@jvolume}(\@jissue),~ \@jpages\else\@jyear\fi &
  View interactive version \href{https://doi.org/ \@paperdoi \if@review .pr\@prround\fi}{here}.
  \end{tabularx}%
}

%\fancyfoot[LE]{%
%  \openlight%
%  \begin{tabularx}{\textwidth}{@{}X  r @{}}%
%  \hline
%  
%  \end{tabularx}%
%}


%TODO Make this a table so that alignment is super easy
\newcommand{\receiveddatahori}{%
  \ifdefempty{\@paperreceived}{}{{\openreg\color{jotedark}Received \hspace*{1mm}}\@paperreceived\\}
  \ifdefempty{\@paperaccepted}{}{{\openreg\color{jotedark}Accepted \hspace*{.5mm}}\@paperaccepted\\}
  \ifdefempty{\@paperpublished}{}{{\openreg\color{jotedark}Published }\@paperpublished\\}
  \ifdefempty{\@paperpublished}{}{{\openreg\color{jotedark}Issued }\@paperissued\\}

}
\newcommand{\receiveddata}{%
  % All this mess is to assure that any combination of \@paperpublished, \@paperreceived and \@paperaccepted will work. It only assumes that \@paperpublished is there, the other two can be there in any combination. Just trust me, it's not worth going through
  &
  \ifdefempty{\@paperreceived}%
    {\ifdefempty{\@paperaccepted}%
    {\multicolumn{1}{@{}l}{Published\ifdefempty{\@rolling}{\if@review \ Online\fi}{ Online}: \@paperpublished}}
    {Accepted: \@paperaccepted, }%
    }
  {Received: \@paperreceived, } &
  \ifdefempty{\@paperreceived}%
    {\ifdefempty{\@paperaccepted}%
        {\multicolumn{1}{@{}l}{}}%
    {\multicolumn{1}{@{}l}{Published\ifdefempty{\@rolling}{}{ Online}: \@paperpublished}}
    }
  {%
    \ifdefempty{\@paperaccepted}%
        {\ifdefempty{\@paperreceived}{\multicolumn{1}{l}{}}{\multicolumn{1}{l}{Published\ifdefempty{\@rolling}{}{ Online}: \@paperpublished}}}
    %
    {Accepted: \@paperaccepted, }
    }&
  \ifdefempty{\@paperreceived}%
    {\multicolumn{1}{l}{}
    }{%
  \ifdefempty{\@paperaccepted}%
        {\multicolumn{1}{c}{}}%
    {Published\ifdefempty{\@rolling}{}{ Online}: \@paperpublished}}%
    &
    \href{\@jwebsite}{https://www.jtrialerror.com}
  }

%% First page header + footer %fph
\fancypagestyle{firstpage}{
\fancyheadoffset[loh,reh,lof]{\myoddoffset}
%   \renewcommand{\footrule}{\hdashrule{\textwidth}{0.5pt}{2pt}\\[-2pt]}
\fancyhead[L]{%
  \if@header
  \hspace{70mm}
  \begin{tabularx}{\linewidth}{@{} l @{}}
      {\color{joteorange!70}\bfseries
      \textls[60]{%
        \Huge\overpass\MakeUppercase{\jote@articletype}}
         \text{   } {\color{joteorange!70}\huge\raisebox{-.1em}{\aiOpenAccess}
                  }
     }
  \end{tabularx}
  \fi
  }
  
  
  \fancyfoot[L]{%
    \fancyheadoffset[loh,reh,lof]{\myoddoffset}
  \setlength{\arrayrulewidth}{.5pt}%
  \arrayrulecolor{betterlightblack}%
  \overpasslight
 % \fontsize{8pt}{13pt}
 \small
  \color{betterlightblack}%
  \if@issue
    \begin{tabularx}{\linewidth}{@{} p{\dimexpr \marginparwidth  + 3mm \relax} l >{\raggedleft\arraybackslash}X | r}%
      &
     \@jname, \textbf{\color{betterlightblack}\@jvolume} (\@jissue) \@jyear
      & \href{https://doi.org/\@paperdoi}{https://doi.org/\@paperdoi}
      & \thepage
    \end{tabularx}%
  \else
    \begin{tabularx}{\linewidth}{@{}p{\dimexpr \marginparwidth + 3mm \relax} l  >{\raggedleft\arraybackslash}X @{}}%
      &
      \@jname, \@jyear
      & \href{https://doi.org/\@paperdoi}{https://doi.org/\@paperdoi}
    \end{tabularx}
  \fi
  }
}

% For adding notes about author contributions
\newcommand{\contrib}[2][]{%
  \blfootnote{\textsuperscript{#1}#2}%
}


% Author and affiliation fonts
\setcounter{Maxaffil}{1}
\renewcommand{\Authsep}{,\text{ } }
\renewcommand{\Authand}{,\text{ } }
\renewcommand{\Authands}{,\text{ } }
\renewcommand{\Authfont}{\overpasslight}
\renewcommand{\Affilfont}{\scriptsize\selectfont}
\renewcommand\AB@authnote[1]{\textsuperscript{#1}}
\patchcmd{\AB@affilsepx}{\\}{\vspace*{3pt}}{}{}

\patchcmd{\@author}{\AB@authlist\vspace*{\affilsep}\AB@affillist}{\AB@authlist}{}{}






\RequirePackage{textpos}

\newcommand{\more@metadata}{%
  
  \jote@affilmetadata
}



%%% Title things

% Coffins
\NewCoffin\MainFrame
\NewCoffin\Logo
\NewCoffin\PaperType
\NewCoffin\Authorx
\NewCoffin\Titlex
\newlength{\AuthSep}
\newlength{\LogoSep}
\newlength{\LogoWidth}

\newcommand{\titlestuff}{
\setlength{\LogoWidth}{4\smallwidth}
\vspace*{3\smallwidth}
\newcommand{\aTitle}{Lorem Ipsum Title\\ Which is too long\\ Too long} % a three lines title
\newcommand{\aLogo}{\includegraphics[width=\LogoWidth]{media/TE_logo_blue_high_res.png}}
\newcommand{\aAuthors}{\@author}
\newcommand{\aWord}{\textsc{Cool}}

%\renewcommand{\aTitle}{Which is too long\\ Too long} % test a two lines title
%\renewcommand{\aTitle}{Which is too long} % test a single line title
%%***********************************************************

%% Design: format of the title, H distance image-title, V distance title-authors <<<<<<<<<<<<
\newcommand{\formatTitle}{\Huge\noindent\raggedright\bfseries\overpass} % format the title
\newcommand{\formatAuthor}{\noindent \raggedright\overpasslight\large}
\setlength{\LogoSep}{17mm}  % horizontal sepation
\setlength{\AuthSep}{2\smallwidth}  % vertical separation
%%***********************************************************

%% Set
\SetHorizontalCoffin\Logo{\aLogo}
\SetHorizontalCoffin\PaperType{\LogoWidth}{}%{\RaggedRight\large\textsc{\jote@articletype}}
\SetVerticalCoffin\Authorx{0.9\textwidth}{\formatAuthor\aAuthors}
\SetVerticalCoffin\Titlex{0.9\textwidth}{\formatTitle\@jotetitle}

% Assembly
\JoinCoffins\MainFrame[l,t]\Logo[l,t] % put the image in the frame
\JoinCoffins\MainFrame[r,vc]\Titlex[l,vc](\LogoSep,0pt) % join the title at an horizontal distance \IntraImage
\JoinCoffins\MainFrame[\Titlex-l,\Titlex-b]\Authorx[l,t](0pt,-\AuthSep) % join the authors with title and dowm \IntraTitle
%\JoinCoffins\MainFrame[\Authorx-l,\Authorx-t]\PaperType[l,t](-\LogoSep-\LogoWidth,0pt) % join the word aligned with authors

%Typeset
\noindent\TypesetCoffin\MainFrame[l,vc](\dimexpr-\LogoSep-15mm, 0pt)  %put the assambly in the page current insertion point
}


%%% measure the size of the titlepage
\newlength{\titleheight}
\setlength{\titleheight}{30mm}
\newlength{\MetaWidth}
%\settototalheight{\titleheight}{\titlestuff}
\newlength{\MetaHeight}

\newcommand{\@insert@metadata}{%
  \setlength{\MetaWidth}{%
  \dimexpr\paperwidth-\textwidth-1.8\marginparsep-\smallwidth%
  }
  
  \setlength{\MetaHeight}{\dimexpr\textheight-\CoffinTotalHeight\MainFrame-5.5\smallwidth}
  
  \begin{textblock*}{\MetaWidth}[0,1](-\MetaWidth,\dimexpr\MetaHeight+\Gm@bmargin -2.2\smallwidth \relax) %\\dimexpr\textheight-\Gm@bmargin-4\smallwidth-1pt\relax)
    \begin{tcolorbox}[%
    enhanced, sharp corners, colback=white, frame hidden,%
    borderline east={0.5pt}{-0em}{joteorange},%
    right skip = \smallwidth, bottom=-4pt,%
    height=\MetaHeight, valign=bottom, left skip=0pt]
\vfill\null
  \setlength{\parskip}{\baselineskip}%
  \setlength{\parindent}{\z@}%
  \jote@affilmetadata
\end{tcolorbox}
  \end{textblock*}
}
\renewcommand{\maketitle}{%
\thispagestyle{firstpage}
\titlestuff
\@insert@metadata%
\normalfont\normalsize%
}




% Affiliation + other metadata
\newcommand{\jote@affilmetadata}{%
  \raggedright
  \scriptsize%
  \AB@affillist\\
  \vspace*{\smallwidth}
  \if@review
  This is \ifdefempty{\@prround}{the originally submitted version}{submission \#\@prround} of \if@noabstract \vskip0pt\fi \enquote{\@title}\if@noabstract\vskip0pt\fi with \ifdefempty{\@prround}{}{round \@prround of the} peer review comments attached.
  {\openreg\color{betterlightblack}Original author(s):} \vskip1pt \textit{\@ogauthor} .
  {\openreg\color{betterlightblack}Published version}\vskip1pt \href{https://doi.org/\@paperdoi}{https://doi.org/\@paperdoi}.
  {\openreg\color{betterlightblack}How to read:} \vskip1pt Sections which have peer review comments are marked by $\bigblacktriangledown$ or \hyperref[sec:reviews]{links},\ifdefempty{\@noabstract}{}{\vskip0pt} clicking which directs you to said comments.\ifdefempty{\@noabstract}{}{\vskip0pt} The reviews contain links referring back to the original section.
  \else
  \ifdefempty{\@contributions}{}{\authfn{2}\@contributions}
  \vskip0pt
  \receiveddatahori
  \vskip\smallwidth
  {\openreg\color{jotedark}Correspondence}\\
  \@corraddress\\
  \@corremail
  \vskip\smallwidth
  \ifdefempty{\@rgainfo}{}{%
   {\bfseries\color{darklightblack}Grant Application to: }%
   \@rgainfo\vskip\smallwidth
 }%
  \ifdefempty{\@funding}{}{%
    {\bfseries\color{betterlightblack}Funding: }%
    \@funding\vskip\smallwidth
}%
{\openreg License}\ \  \faIcon{creative-commons}\  \faIcon{creative-commons-by}\\
  {\color{darklightblack}This article is licensed under the {\openreg\href{https://www.creativecommons.org/licenses/by-nc-nd/4.0/legalcode}{Creative Commons Attirbution 4.0 (CC-BY 4.0)}} license, which allows you to copy, redistribute, transform and build upon the article and all its contents in any medium or format for any purpose, provided that appropriate credit is given.}
  
    \textcopyright\space \@runningauthor\ \@jyear\\

  \vskip\smallwidth%
  \href{https://crossmark.crossref.org/dialog/?doi=\@paperdoi\&domain=pdf\&date_stamp=\@paperpublisheddate}{\includegraphics[height=2em]{media/CROSSMARK_Color_horizontal.png}}%

  \fi%
}

%% Abbreviations in the footnote
\newcommand{\abbrevs}[1]{\blfootnote{{\bfseries\color{betterlightblack}Abbreviations:} #1\vspace*{-3pt}}}

%% Abstract and affiliation in the margin
\RequirePackage{changepage}
\RequirePackage{environ}
\RequirePackage{marginnote}

\newlength{\jote@affilmetadataheight}
\newlength{\jote@abstractheight}
\newlength{\jote@newaffilwidth}
\newlength{\jote@newabstractwidth}
\newlength{\jote@newheight}
\NewEnviron{jote@abstract}{%
  \newcommand{\keywords}[1]{%
    \vskip\smallwidth
    \noindent{{\color{darklightblack}\textbf{Keywords}}\ }
    \noindent{ \textit{##1}\par}
  }%
  \if@noabstract\vspace*{2\smallwidth}\else
  \strictpagecheck%
  \checkoddpage
  \ifoddpage \reversemarginpar  \begin{adjustwidth*}{\dimexpr \@heightabstract+0pt}{}%
  \else  \reversemarginpar \begin{adjustwidth*}{}{\dimexpr \@heightabstract+0pt}%
  \fi
  \vspace*{2\smallwidth}

  {\normalsize\selectfont
  \BODY
  }
    \keywords{\textit{\@keywordsabstract}}
  \end{adjustwidth*}
  \vspace*{2\smallwidth}
  \fi
}%

\renewcommand{\abstract}{\jote@abstract}
\renewcommand{\endabstract}{\endjote@abstract}

\newcommand{\thefpfootnotes}{%
  \noindent\textcolor{black!50}{\rule{\textwidth}{0.5pt}}\\
  {\scriptsize\selectfont
  \@fpfootnotes}
}

\definecolor{pinky}{HTML}{f3e1ce}
%% v1.4: Add two-column mode
\NewEnviron{frontmatter}{%
   \if@twocolumn
    \let\oldclearpage\clearpage
    \let\clearpage\relax
    \ifdefvoid{\@fpfootnotes}{}{%
       \begin{figure*}[b!]
       \thefpfootnotes
       \end{figure*}
     }%
    \twocolumn[\@twocolumnfalse\setlength\parindent{2em}\BODY]%
    \let\clearpage\oldclearpage
   \else
     \BODY
   \fi%
}


%%%%%
% Headings
%%%%%



\RequirePackage[explicit]{titlesec}

\titleformat{\section}[block]{}{}{0pt}{\Large}
\titleformat{name=\section}[block]
     {}
 {}{0pt}{\normalsize\bfseries\raggedright#1}

 \titlespacing*{\section}{0pt}{\dimexpr\baselineskip}{\dimexpr\baselineskip-0pt}
 \titlespacing*{name=\section,numberless}{0pt}{\baselineskip}{0pt}

 \titleformat{\subsection}[block]
   {\raggedright}
   {}{0pt}{\normalsize\openreg#1}

 \titlespacing*{\subsection}{0pt}{\dimexpr\baselineskip }{2pt}

 \titleformat{\subsubsection}[block]
   {\raggedright}
   {}{0pt}{\normalsize\selectfont\itshape #1}%Textls sets spacing. 100 is a bit, can take big numbers
 \titlespacing*{\subsubsection}{0pt}{\dimexpr.5\baselineskip }{.5\baselineskip}

     \titleformat{name=\paragraph}[runin]
       {\mdseries}
       {}{0pt}{#1\ \ }
     \titleformat{\subparagraph}[runin]
       {}%
       {}{0pt}{\textit{#1}\ \ \ }

 \titlespacing*{\paragraph}{}{\baselineskip}{0pt}
 \titlespacing*{\subparagraph}{\parindent}{\baselineskip}{0pt}




\renewcommand\marginfont{\RaggedRight\footnotesize}


% quotes and epigraphs
\RequirePackage{quoting}
\quotingsetup{vskip=\baselineskip,indentfirst=false,leftmargin=26pt,rightmargin=26pt}

\renewenvironment{quote}{\begin{quoting}}{\end{quoting}}

\renewenvironment{quotation}{\begin{quoting}}{\end{quoting}}
\AtBeginEnvironment{quoting}{\small \itshape \color{black!80}}

\newenvironment{epigraph}[1]
{\begin{quoting}\def\@quotesource{#1}}
{\par\hfill\@quotesource\end{quoting}}

\newenvironment{pullquote}
{\begin{quoting}[vskip=\dimexpr 39pt-23pt\relax,leftmargin=12pt,rightmargin=12pt,font+={raggedright},begintext={\fontsize{18pt}{23pt}\sffamily\mdseries\color{black!50}}]}
{\end{quoting}}

% Enum/itemized
\RequirePackage[inline]{enumitem}
\setlist{nosep,font=\bfseries,leftmargin=*,align=left}
\setlist[1]{topsep=\baselineskip,leftmargin=\parindent,labelsep=*,labelwidth=*}
\setlist[enumerate,2]{label={\alph*.},}

% Space above/below equations
\g@addto@macro\normalsize{%
  \setlength\abovedisplayskip{\baselineskip}%
  \setlength\belowdisplayskip{\baselineskip}%
  \setlength\abovedisplayshortskip{\baselineskip}%
  \setlength\belowdisplayshortskip{\baselineskip}%
}

% All the popular math environments
\newtheorem{theorem}{Theorem}
\newtheorem{lemma}{Lemma}
\newtheorem{proposition}{Proposition}
\newtheorem{corollary}{Corollary}

\newenvironment{proof}[1][Proof]{\begin{trivlist}
\item[\hskip \labelsep {\bfseries #1}]}{\end{trivlist}}
\newenvironment{definition}[1][Definition]{\begin{trivlist}
\item[\hskip \labelsep {\bfseries #1}]}{\end{trivlist}}
\newenvironment{example}[1][Example]{\begin{trivlist}
\item[\hskip \labelsep {\bfseries #1}]}{\end{trivlist}}
\newenvironment{remark}[1][Remark]{\begin{trivlist}
\item[\hskip \labelsep {\bfseries #1}]}{\end{trivlist}}

\newcommand{\qed}{\nobreak \ifvmode \relax \else
      \ifdim\lastskip<1.5em \hskip-\lastskip
      \hskip1.5em plus0em minus0.5em \fi \nobreak
      \vrule height0.75em width0.5em depth0.25em\fi}

% Captions
    \RequirePackage{caption}
%\captionsetup*[table]{skip=0.5ex}

% Tables
\RequirePackage{stfloats} %hopefully lead to better table placement
\AtBeginEnvironment{table}{%
  \renewcommand{\arraystretch}{1.25}%
  \setlength{\arrayrulewidth}{1pt}%
}
\AtBeginEnvironment{table*}{%
  \renewcommand{\arraystretch}{1.25}%
  \setlength{\arrayrulewidth}{1pt}%
}
\RequirePackage{threeparttable}
\renewcommand{\TPTnoteSettings}{\leftmargin=0pt}
\newcommand{\headrow}{\rowcolor{black!20}}
\newcommand{\thead}[1]{\multicolumn{1}{l}{\bfseries #1\rule[-1.2ex]{0pt}{2em}}}





% References
% Authordate just uses biblatex apa
\if@numeric
  \RequirePackage[backend=biber, citestyle=numeric-comp, sorting=none, bibstyle=apa]{biblatex}
  \AtEndPreamble{\makeatletter
    \input{numeric.bbx}
  \makeatother}
\fi
\if@authordate
    \RequirePackage[backend=biber, style=apa]{biblatex}
\fi





% This is just to make the year in the citations slightly bold...
% It's just  a redefine of the normal apa bibmacro that does this, 
% couldn't find a cleaner way to do this.
\renewbibmacro*{cite:plabelyear+extradate}{
\openreg
  \iffieldundef{labelyear}{}
    {\printtext[bibhyperref]{%
        \clearfield{labelmonth}% don't want months in citations
        \clearfield{labelday}% don't want days in citations
        \clearfield{labelendmonth}% don't want months in citations
        \clearfield{labelendday}% don't want days in citations
        \clearfield{labelyeardivision}% don't want yeardivisions in citations
        \clearfield{labelendyeardivision}% don't want yeardivisions in citations
        \iffieldsequal{labelyear}{labelendyear}% Don't want no-op year ranges
          {\clearfield{labelendyear}}
          {}%
        \iffieldundef{origyear}
          {}
          {\printorigdate%
           \setunit*{\addslash}}%
        \iffieldundef{related}
          {}
          {\iffieldequalstr{relatedtype}{reprintfrom}
            {\entrydata*{\thefield{related}}{\printlabeldateextra}%
             \setunit*{\addslash}}
            {}}%
        \printlabeldateextra}}}
        

% Make the indentation of bib info not as dramatic like get over yourself

%\AtBeginDocument{
\setlength{\bibhang}{\parindent}
\setlength{\bibitemsep}{0.3\smallwidth}
%}

\defbibheading{bibliography}[\refname]{\section{#1}}

% Make the bib size slightly smaller, it's not that important

\renewcommand*\bibfont{\normalfont\small}

\newcommand{\otherinfo}[2][]{%
  \backmatter%
  \ifstrequal{#1}{suppinfo}
  {\section{Supporting Information}
  Additional Supporting Information may be found online in the supporting information for this article.}
  {}

  \begin{mdframed}
  [linewidth=1pt,linecolor=black!40,nobreak,
    innerleftmargin=12pt,innerrightmargin=12pt,
    innertopmargin=12pt,innerbottommargin=12pt,
    skipabove=\baselineskip]
  {\bfseries\color{betterlightblack}How to cite this article:} #2
  \end{mdframed}
}

\newenvironment{graphicalabstract}[1]{%
  \backmatter
  \section{graphical abstract}
  \lettrine[image,lines=10,findent=\smallwidth,nindent=0pt]{#1}{}%
}{}

%Append all the necessecary things after the references (license, copyright, acknowledgements)
\RequirePackage{wrapfig}
\apptocmd{\printbibliography}{%
    \ifdefempty{\@companionkey}{}{
    \ifdefempty{\@acknowledgments}{}{%
    \section{Acknowledgments}%
    \@acknowledgments}}%
    \ifdefempty{\@interests}{}{\section{Conflict of Interest}\@interests}
  }{}{}


% Here we go!

% Set some lengths that might get set otherwise
\setlength{\textfloatsep}{1\smallwidth}
%\setlength{\intextsep}{0pt}
%\setlength{\floatsep}{0pt}
%\setlength{\bibhang}{\parindent}
\setlength{\parskip}{0pt}

% This will give you MUCH more useful errors
\setcounter{errorcontextlines}{30}
%\normalsize
\pagestyle{fancy}
\AtEndPreamble{%
    % \captionsetup[table]{tableposition=top, singlelinecheck=false, labelfont=bf, labelsep=quad, size=small}
    \captionsetup{tableposition=top,figureposition=bottom, singlelinecheck=false, labelfont=bf, labelsep=quad ,size=small, textfont={color={darklightblack}, small}, justification=RaggedRight}
}
\AtBeginDocument{%
  \robustify{\ref}
  \robustify{\cite}
  \ifdef{\citep}{\robustify{\citep}}{}
  \ifdef{\citet}{\robustify{\citet}}{}
}

% Local Variables:
% TeX-engine: lualatex
% End:
