%%
%% skyalert-report.cls — SkyAlert RED · AI Station · Installation Report
%% v6.0  2026-04-10  —  pdfLaTeX / LuaLaTeX / XeLaTeX compatible
%%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{skyalert-report}[2026/04/10 v6.0 SkyAlert RED Installation Report]

\LoadClass[a4paper,11pt]{article}

%% ── Packages ──────────────────────────────────────────────────────────────
\RequirePackage[
  a4paper,
  top=22mm, bottom=18mm, left=16mm, right=16mm,
  headheight=14mm, headsep=6mm, footskip=12mm,
  includeheadfoot
]{geometry}
\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}
\RequirePackage{textcomp}
\RequirePackage[expansion=false]{microtype}
\RequirePackage[table]{xcolor}
\RequirePackage{graphicx}
\RequirePackage{array,colortbl,booktabs}
\RequirePackage{enumitem}
\RequirePackage[hyphens]{url}
\RequirePackage{hyperref}
\RequirePackage{tcolorbox}
\RequirePackage{tikz}
\RequirePackage{etoolbox}
\RequirePackage{calc}
\RequirePackage{fontawesome5}
\RequirePackage{fancyhdr}
\RequirePackage{sourcesanspro}
\RequirePackage{sourcecodepro}
\RequirePackage{lastpage}
\RequirePackage{ragged2e}
\tcbuselibrary{skins,breakable}
\usetikzlibrary{calc,positioning}

\hypersetup{colorlinks=true,urlcolor=accent,linkcolor=charcoal,pdfstartview=FitH}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}
\renewcommand{\arraystretch}{1.2}

%% ── Colour palette ───────────────────────────────────────────────────────
\definecolor{charcoal}{HTML}{0F1114}
\definecolor{darkbg}{HTML}{181B20}
\definecolor{skyred}{HTML}{C0272D}
\definecolor{accent}{HTML}{D63440}
\definecolor{redlight}{HTML}{F07078}
\definecolor{steel}{HTML}{5C6670}
\definecolor{mist}{HTML}{9EAAB4}
\definecolor{silver}{HTML}{CBD3DA}
\definecolor{divider}{HTML}{DDE3E7}
\definecolor{pagebg}{HTML}{F4F6F8}
\definecolor{tablebg}{HTML}{EBEEF1}
\definecolor{tablerow}{HTML}{F4F6F8}
\definecolor{white95}{HTML}{F8F9FA}
\definecolor{greenbg}{HTML}{E6F4ED}
\definecolor{greendark}{HTML}{0D7A3E}
\definecolor{greenaccent}{HTML}{22C55E}
\definecolor{amberbg}{HTML}{FFF8E1}
\definecolor{amberdark}{HTML}{D97706}
\definecolor{redbg}{HTML}{FEE2E2}
\definecolor{reddark}{HTML}{DC2626}
\definecolor{mqttbg}{HTML}{0D1117}
\definecolor{mqttframe}{HTML}{30363D}
\definecolor{mqttgreen}{HTML}{3FB950}
\definecolor{mqttcyan}{HTML}{58A6FF}
\definecolor{mqttdim}{HTML}{8B949E}

%% ── Metadata commands ─────────────────────────────────────────────────────
\newcommand{\sitename}[1]{\def\@sitename{#1}}
\newcommand{\sitelocation}[1]{\def\@sitelocation{#1}}
\newcommand{\installdate}[1]{\def\@installdate{#1}}
\newcommand{\stationid}[1]{\def\@stationid{#1}}
\newcommand{\sensormodel}[1]{\def\@sensormodel{#1}}
\newcommand{\folio}[1]{\def\@folio{#1}}
\newcommand{\reportid}[1]{\def\@reportid{#1}}
\newcommand{\authorname}[1]{\def\@authorname{#1}}
\newcommand{\supportnames}[1]{\def\@supportnames{#1}}
\newcommand{\revision}[1]{\def\@revision{#1}}
\newcommand{\coverlogo}[1]{\def\@coverlogo{#1}}
\newcommand{\seismiczone}[1]{\def\@seismiczone{#1}}
\newcommand{\siteaddress}[1]{\def\@siteaddress{#1}}
\newcommand{\sitemaps}[1]{\def\@sitemaps{#1}}
\newcommand{\sitelat}[1]{\def\@sitelat{#1}}
\newcommand{\sitelong}[1]{\def\@sitelong{#1}}
\newcommand{\sitealt}[1]{\def\@sitealt{#1}}
\newcommand{\totalpages}[1]{\def\@totalpages{#1}}
\def\@totalpages{6}
\def\@revision{v6.0}

%% ── Header / Footer ──────────────────────────────────────────────────────
\pagestyle{fancy}
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
\renewcommand{\footrulewidth}{0pt}

%% Punto 2: header con logo de SkyAlert (sin invertir) y texto más visible
\fancyhead[C]{%
  \begin{tikzpicture}[remember picture,overlay]
    \fill[darkbg]
      ([yshift=2mm]current page.north west) rectangle
      ([yshift=-15mm]current page.north east);
    \fill[skyred]
      ([yshift=-15mm]current page.north west) rectangle
      ([yshift=-17.5mm]current page.north east);
  \end{tikzpicture}%
  \vspace{-3mm}%
  \makebox[\textwidth]{%
    %% Logo SkyAlert en header (más grande, sin texto SKYALERT RED)
    \raisebox{-1pt}{%
      \begin{tikzpicture}[baseline=0pt]
        \node[fill=white,rounded corners=2pt,inner sep=2pt]{%
          \includegraphics[height=9mm]{\@coverlogo}%
        };
      \end{tikzpicture}%
    }%
    \hfill
    {\normalsize\bfseries\textcolor{silver}{\@headertext}}%
    \enspace{\normalsize\textcolor{mist}{$|$}}\enspace%
    {\normalsize\textcolor{silver}{P\'ag.\ \thepage\ / \@totalpages}}%
  }%
}

%% Footer
\fancyfoot[C]{%
  \textcolor{divider}{\rule{\textwidth}{0.4pt}}\\[2mm]%
  {\footnotesize\textcolor{mist}{%
    \textcolor{skyred}{\rule{5mm}{1.2pt}}\enspace
    SkyAlert RED\enspace\textperiodcentered\enspace Reporte de Instalaci\'on%
  }}%
  \hfill
  {\footnotesize\textcolor{mist}{\@footertext}}%
}

\newcommand{\@headertext}{}
\newcommand{\@footertext}{}
\newcommand{\setheadertext}[1]{\renewcommand{\@headertext}{#1}}
\newcommand{\setfootertext}[1]{\renewcommand{\@footertext}{#1}}

\fancypagestyle{cover}{%
  \fancyhf{}\renewcommand{\headrulewidth}{0pt}\renewcommand{\footrulewidth}{0pt}%
}

%% ── Status chips ─────────────────────────────────────────────────────────
\tikzset{skychip/.style={rounded corners=2pt,inner xsep=4pt,inner ysep=2pt,font=\bfseries\scriptsize}}
\newcommand{\chipok}[1]{%
  \tikz[baseline=(N.base)]\node[skychip,fill=greenbg,text=greendark](N){\faIcon{check}\enspace#1};%
}
\newcommand{\chipna}[1]{%
  \tikz[baseline=(N.base)]\node[skychip,fill=tablebg,text=mist](N){\faIcon{minus}\enspace#1};%
}
\newcommand{\chipwarn}[1]{%
  \tikz[baseline=(N.base)]\node[skychip,fill=amberbg,text=amberdark](N){\faIcon{exclamation-triangle}\enspace#1};%
}
\newcommand{\chipfail}[1]{%
  \tikz[baseline=(N.base)]\node[skychip,fill=redbg,text=reddark](N){\faIcon{times-circle}\enspace#1};%
}

%% ── Table header ─────────────────────────────────────────────────────────
\newcommand{\thead}[1]{\textcolor{white}{\footnotesize\bfseries #1}}

%% ── Section heading ──────────────────────────────────────────────────────
\newcommand{\sectionhead}[1]{%
  \vspace{4mm}%
  {\fontsize{13}{15}\selectfont\bfseries\textcolor{charcoal}{#1}}\\[-0.5mm]%
  \textcolor{skyred}{\rule{14mm}{2pt}}\textcolor{divider}{\rule{\dimexpr\textwidth-14mm\relax}{0.5pt}}%
  \vspace{3mm}\par%
}

%% ── Subsection label ─────────────────────────────────────────────────────
\newcommand{\subsectionlabel}[1]{%
  \vspace{3mm}%
  {\small\bfseries\textcolor{steel}{\MakeUppercase{#1}}}\\[1mm]%
  \textcolor{divider}{\rule{\textwidth}{0.4pt}}\vspace{2mm}\par%
}

%% ── Data field ────────────────────────────────────────────────────────────
\newcommand{\datafield}[2]{%
  \begin{minipage}[t]{\linewidth}\vspace{1mm}%
    {\scriptsize\bfseries\textcolor{steel}{\MakeUppercase{#1}}}\\[0.5mm]%
    {\small\bfseries\textcolor{charcoal}{#2}}\vspace{1.5mm}%
  \end{minipage}%
}

%% ── Card environment ─────────────────────────────────────────────────────
\newenvironment{card}{%
  \begin{tcolorbox}[
    enhanced,colback=tablebg,colframe=divider,boxrule=0.4pt,
    arc=4pt,left=8pt,right=8pt,top=6pt,bottom=6pt,
    shadow={0.4mm}{-0.4mm}{0mm}{black!8}
  ]%
}{\end{tcolorbox}}

%% ── Photo frame ──────────────────────────────────────────────────────────
\newcommand{\photoframe}[2]{% {image}{caption}
  \begingroup\centering
  \includegraphics[width=\linewidth,height=34mm,keepaspectratio]{#1}%
  \par\vspace{1mm}%
  {\footnotesize\itshape\textcolor{steel}{#2}\par}%
  \endgroup
}

%% ── Observation box ──────────────────────────────────────────────────────
\newenvironment{obsbox}{%
  \begin{tcolorbox}[
    enhanced,colback=tablebg,colframe=divider,boxrule=0.4pt,
    arc=3pt,left=10pt,right=10pt,top=8pt,bottom=8pt,
    borderline west={3pt}{0pt}{skyred}
  ]%
}{\end{tcolorbox}}

%% ── KPI block ────────────────────────────────────────────────────────────
\newcommand{\kpiblock}[3]{% {icon}{value}{label}
  \begin{tcolorbox}[
    enhanced,colback=tablebg,colframe=divider,boxrule=0.3pt,
    arc=4pt,width=\linewidth,left=4pt,right=4pt,top=5pt,bottom=5pt,
    equal height group=kpi
  ]
  \centering
  {\large\textcolor{skyred}{#1}}\\[1.5mm]
  {\fontsize{18}{20}\selectfont\bfseries\textcolor{charcoal}{#2}}\\[1mm]
  {\tiny\bfseries\textcolor{steel}{\MakeUppercase{#3}}}
  \end{tcolorbox}%
}

%% ── Signature block (punto 5: fixed height, contenido dentro) ────────────
\newcommand{\signblock}[4]{% {title}{name}{cargo}{fecha}
  \begin{tcolorbox}[
    enhanced,colback=white,colframe=silver,boxrule=0.4pt,
    arc=4pt,width=\linewidth,
    left=0pt,right=0pt,top=0pt,bottom=0pt,
    height=62mm,
    shadow={0.3mm}{-0.3mm}{0mm}{black!6}
  ]
  \colorbox{darkbg}{\parbox{\dimexpr\linewidth-2\fboxsep\relax}{%
    \vspace{2mm}\hspace{6pt}%
    {\small\bfseries\textcolor{white}{#1}}%
    \vspace{2mm}%
  }}
  \vspace{2mm}

  \hspace{6pt}\begin{minipage}{\dimexpr\linewidth-12pt\relax}
  {\scriptsize\bfseries\textcolor{steel}{}}\\[0.5mm]%
  {\small\bfseries #2}\\[0.5mm]%
  \textcolor{divider}{\rule{\linewidth}{0.4pt}}\vspace{1.5mm}

  {\scriptsize\bfseries\textcolor{steel}{CARGO}}\\[0.5mm]%
  {\small #3}\\[0.5mm]%
  \textcolor{divider}{\rule{\linewidth}{0.4pt}}\vspace{1.5mm}

  {\scriptsize\bfseries\textcolor{steel}{FECHA}}\\[0.5mm]%
  {\small #4}\\[0.5mm]%
  \textcolor{divider}{\rule{\linewidth}{0.4pt}}\vspace{1.5mm}

  {\scriptsize\bfseries\textcolor{steel}{FIRMA}}\vspace{4mm}

  \textcolor{divider}{\rule{\linewidth}{0.4pt}}
  \end{minipage}
  \end{tcolorbox}%
}

%% ── Cover page ────────────────────────────────────────────────────────────
\newcommand{\makecover}{%
\thispagestyle{cover}%
\begin{tikzpicture}[remember picture,overlay]
  \fill[charcoal](current page.north west)rectangle(current page.south east);
  \foreach \x in {0,12,...,210}{
    \draw[white,opacity=0.02,line width=0.3pt]
      ([xshift=\x mm]current page.north west)--([xshift=\x mm]current page.south west);
  }
  \foreach \y in {0,12,...,297}{
    \draw[white,opacity=0.02,line width=0.3pt]
      ([yshift=-\y mm]current page.north west)--([yshift=-\y mm]current page.north east);
  }
  \fill[skyred](current page.north west)rectangle([yshift=-5pt]current page.north east);
  \begin{scope}[shift={($(current page.center)+(0,20mm)$)}]
    \draw[skyred,opacity=0.06,line width=2.5pt,smooth]
      plot[domain=-7:7,samples=80](\x,{1.0*sin(\x*100)*exp(-0.12*abs(\x))});
  \end{scope}
  \fill[black!40!charcoal](current page.south west)rectangle([yshift=22mm]current page.south east);
\end{tikzpicture}%
%
\vspace*{10mm}

%% ── Punto 1: Logo SkyAlert a la izquierda, iconos a la derecha alineados
\noindent
\ifdefined\@coverlogo
  \begin{tikzpicture}[baseline=0pt]
    \node[fill=white,rounded corners=4pt,inner sep=4pt]{%
      \includegraphics[height=12mm]{\@coverlogo}%
    };
  \end{tikzpicture}%
\fi
%% Iconos a la derecha: solo AI Station
\hfill
\begin{tikzpicture}[baseline=0pt]
  \node[fill=skyred,rounded corners=3pt,inner xsep=8pt,inner ysep=3.5pt]{%
    \bfseries\small\textcolor{white}{AI Station}%
  };
\end{tikzpicture}%

\vspace{16mm}\par
{\footnotesize\bfseries\textcolor{redlight}{\faIcon{file-alt}\enspace REPORTE DE INSTALACI\'ON}}\par

\vspace{4mm}
{\fontsize{30}{34}\selectfont\bfseries\textcolor{white}{Estaci\'on S\'ismica}}\par\vspace{2mm}%
{\fontsize{30}{34}\selectfont\bfseries\textcolor{redlight}{Inteligente}}\par

\vspace{5mm}
%% Punto 1: nombre y ubicación más visibles
{\large\bfseries\textcolor{white}{\@sitename}}\par\vspace{2mm}%
{\normalsize\textcolor{silver}{\faIcon{map-marker-alt}\enspace\@sitelocation}}\par

\vspace{10mm}
\textcolor{skyred}{\rule{16mm}{2.5pt}}\par

\vspace{14mm}
%% Punto 1: encabezados de metadata más visibles
\begin{tabular}{@{}p{70mm}p{70mm}@{}}
{\small\textcolor{silver}{\faIcon{calendar-alt}\enspace FECHA DE INSTALACI\'ON}} &
{\small\textcolor{silver}{\faIcon{microchip}\enspace ID DE ESTACI\'ON}} \\[1mm]
{\large\bfseries\textcolor{white}{\@installdate}} &
{\large\bfseries\textcolor{white}{\@stationid}} \\[6mm]
{\small\textcolor{silver}{\faIcon{satellite-dish}\enspace MODELO DE SENSOR}} &
{\small\textcolor{silver}{\faIcon{hashtag}\enspace FOLIO}} \\[1mm]
{\large\bfseries\textcolor{white}{\@sensormodel}} &
{\large\bfseries\textcolor{white}{\@folio}} \\
\end{tabular}

\vfill
\vspace*{2mm}
\begin{tabular}{@{}p{70mm}p{65mm}r@{}}
{\small\textcolor{silver}{\faIcon{user}\enspace ELABORADO POR}} &
{\small\textcolor{silver}{\faIcon{users}\enspace APOYO EN INSTALACI\'ON}} & \\[1mm]
{\normalsize\bfseries\textcolor{white}{\@authorname}} &
{\normalsize\bfseries\textcolor{white}{\@supportnames}} &
{\scriptsize\textcolor{mist}{\@revision}} \\
\end{tabular}%
\vspace{4mm}
\newpage
}

\endinput
