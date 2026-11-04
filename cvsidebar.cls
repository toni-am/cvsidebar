% =============================================================================
% sidebarcv.cls — Two-column CV/resume with shaded sidebar
% =============================================================================
% Compiles with pdfLaTeX (needs a 2020+ LaTeX kernel for expl3/xparse).
% Options: a4paper (default), letterpaper, 10pt (default), 11pt, 12pt
% =============================================================================

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{sidebarcv}[2026/10/22 v1.0 Sidebar CV]

% -----------------------------------------------------------------------------
% Class options
% -----------------------------------------------------------------------------
\def\cv@paper{a4paper}
\newif\ifcv@fullpagesb
\cv@fullpagesbfalse
\DeclareOption{a4paper}{\def\cv@paper{a4paper}}
\DeclareOption{letterpaper}{\def\cv@paper{letterpaper}}
\DeclareOption{fullpagesb}{\cv@fullpagesbtrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass{article}
% -----------------------------------------------------------------------------
% Packages
% -----------------------------------------------------------------------------
\RequirePackage[T1]{fontenc}
% For other fonts with XeTeX/LuaTeX, load fontspec in main.tex, e.g.
%   \usepackage{fontspec}\setmainfont{TeX Gyre Heros}
\RequirePackage[\cv@paper,margin=0.55in]{geometry}
\RequirePackage{xcolor}
\RequirePackage{enumitem}
\RequirePackage{etoolbox}
\RequirePackage[hidelinks]{hyperref}
\RequirePackage{graphicx}      % for \resizebox in \socialicon
\RequirePackage{fontawesome5}
\ifcv@fullpagesb\RequirePackage{eso-pic}\fi % sidebar fills entire page

% -----------------------------------------------------------------------------
% Layout and colors (override in main.tex after \documentclass)
% -----------------------------------------------------------------------------
\pagestyle{empty}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}

\definecolor{cvdeep}{HTML}{213547}
\definecolor{cvaccent}{HTML}{C56B2C}
\definecolor{cvrail}{HTML}{EEF2F4}
\definecolor{cvsecondary}{HTML}{4A5568}
\definecolor{cvlight}{HTML}{718096}

\newcommand{\cvsidebarwidth}{0.29\textwidth}
\newcommand{\cvmainwidth}{0.67\textwidth}
\newcommand{\cvitemsep}{5pt}

\setlist[itemize]{leftmargin=1.1em,itemsep=2pt,topsep=2pt}

% -----------------------------------------------------------------------------
% Columns
%   \begin{cvsidebar} ... \end{cvsidebar}\hfill%
%   \begin{cvmain} ... \end{cvmain}
% The sidebar can be in a box (default) or take the full page (fullpagesb)
% -----------------------------------------------------------------------------
\newcommand{\cvsidebarfontsize}{\normalsize}
\newlength{\cvsidebarpad}
\setlength{\cvsidebarpad}{8pt}   % full-page: space between text and shading edge

\ifcv@fullpagesb
  % ---- full-page version: shading drawn as page background, page 1 only ----
  \newenvironment{cvsidebar}
    {\AddToShipoutPictureBG*{%
       \AtPageLowerLeft{%
         \color{cvrail}%
         \rule{\dimexpr 1in+\hoffset+\oddsidemargin+\cvsidebarwidth\relax}%
              {\paperheight}}}%
     \begin{minipage}[t]{\dimexpr\cvsidebarwidth-\cvsidebarpad\relax}%
     \sffamily\cvsidebarfontsize\raggedright}
    {\par\end{minipage}}
\else
  % ---- box version (default): shading is as tall as the content ----
  \newsavebox{\cv@sidebarbox}
  \newenvironment{cvsidebar}
    {\begin{minipage}[t]{\cvsidebarwidth}%
     \setlength{\fboxsep}{8pt}%
     \begin{lrbox}{\cv@sidebarbox}%
     \begin{minipage}[t]{\dimexpr\linewidth-2\fboxsep\relax}%
     \sffamily\cvsidebarfontsize\raggedright}
    {\par\end{minipage}\end{lrbox}%
     \colorbox{cvrail}{\usebox{\cv@sidebarbox}}%
     \end{minipage}}
\fi

% -----------------------------------------------------------------------------
% cvmain - the non sidebar part
% -----------------------------------------------------------------------------
\newenvironment{cvmain}
  {\begin{minipage}[t]{\cvmainwidth}\raggedright}
  {\par\end{minipage}}

% -----------------------------------------------------------------------------
% cvfirstpage - wraps the sidebar + main column block (page 1 only).
% Everything after \end{cvfirstpage} is normal full-width text that can
% break across pages.
% -----------------------------------------------------------------------------
\newenvironment{cvfirstpage}
  {\par\noindent}
  {\par\vspace{\cvitemsep}}

% -----------------------------------------------------------------------------
% \cvsection{title} — heading with colored rule
% -----------------------------------------------------------------------------
\newlength{\cvsectionrulesep}
\setlength{\cvsectionrulesep}{-8pt}

\newcommand{\cvsection}[1]{%
  \par\vspace{7pt}%
  {\large\bfseries\color{cvdeep}#1\par}%
  \vspace{\cvsectionrulesep}%
  {\color{cvaccent}\rule{\linewidth}{1.2pt}\par}%
  \vspace{2pt}%
}

% -----------------------------------------------------------------------------
% \cvlines{a, b, c} — comma-separated list, one item per line
% (wrap items containing commas in braces)
% -----------------------------------------------------------------------------
\ExplSyntaxOn
\clist_new:N \l__cv_lines_clist
\NewDocumentCommand{\cvlines}{m}
  {
    \clist_set:Nn \l__cv_lines_clist {#1}
    \clist_use:Nn \l__cv_lines_clist { \\ }
    \par
  }
\ExplSyntaxOff

% -----------------------------------------------------------------------------
% \cvheader{ name = ..., tagline = ... }
% -----------------------------------------------------------------------------
\ExplSyntaxOn
\keys_define:nn { cvheader }
  {
    name    .code:n = { \def\cvh@name{#1} },
    tagline .code:n = { \def\cvh@tagline{#1} },
  }
\cs_new_eq:NN \cvheadersetkeys \keys_set:nn
\ExplSyntaxOff

\NewDocumentCommand{\cvheader}{+m}{%
  \def\cvh@name{}\def\cvh@tagline{}%
  \cvheadersetkeys{cvheader}{#1}%
  \ifdefempty{\cvh@name}{}{%
    {\fontsize{20}{23}\selectfont\bfseries\color{cvdeep}\cvh@name\par}\vspace{3pt}}%
  \ifdefempty{\cvh@tagline}{}{%
    {\large\cvh@tagline\par}\vspace{10pt}}%
  \hypersetup{pdfauthor={\cvh@name},pdftitle={\cvh@name\ -- CV}}%
}

% -----------------------------------------------------------------------------
% \cvcontact{ email, phone, location, website, linkedin, github, bitbucket,
%             scholar, orcid }
%   email     : address
%   phone     : phone number
%   location  : free text
%   website   : given without https://
%   linkedin  : profile id (linkedin.com/in/<id>)
%   github    : user name
%   bitbucket : user name
%   scholar   : Google Scholar user id
%   orcid     : ORCID id (0000-0000-0000-0000)
% One line per item, each preceded by its icon. Empty keys are skipped.
% -----------------------------------------------------------------------------
\newcommand{\cvcontacticonwidth}{2.0em} %icon width
\newcommand{\socialicon}[1]{\raisebox{-0.05em}{\resizebox{!}{1em}{#1}}}
\newlength{\cvcontactsep}
\setlength{\cvcontactsep}{4pt} %separation between lines

\ExplSyntaxOn
\keys_define:nn { cvcontact }
  {
    email     .code:n = { \def\cvc@email{#1} },
    phone     .code:n = { \def\cvc@phone{#1} },
    location  .code:n = { \def\cvc@location{#1} },
    website   .code:n = { \def\cvc@website{#1} },
    linkedin  .code:n = { \def\cvc@linkedin{#1} },
    github    .code:n = { \def\cvc@github{#1} },
    bitbucket .code:n = { \def\cvc@bitbucket{#1} },
    scholar   .code:n = { \def\cvc@scholar{#1} },
    orcid     .code:n = { \def\cvc@orcid{#1} },
  }
\cs_new_eq:NN \cvcontactsetkeys \keys_set:nn
\ExplSyntaxOff

% \cvc@line{macro to test}{icon}{content}
% Icon sits in a fixed-width box; wrapped lines are indented under the text.
\newcommand{\cvc@line}[3]{%
  \ifdefempty{#1}{}{%
    {\hangindent=\cvcontacticonwidth\hangafter=1\noindent
      \makebox[\cvcontacticonwidth][l]{\color{cvdeep}\socialicon{#2}}#3\par}%
    \vspace{\cvcontactsep}%
  }%
}

\NewDocumentCommand{\cvcontact}{+m}{%
  \def\cvc@email{}\def\cvc@phone{}\def\cvc@location{}\def\cvc@website{}%
  \def\cvc@linkedin{}\def\cvc@github{}\def\cvc@bitbucket{}%
  \def\cvc@scholar{}\def\cvc@orcid{}%
  \cvcontactsetkeys{cvcontact}{#1}%
  \cvc@line{\cvc@email}{\faIcon{envelope}}%
    {\href{mailto:\cvc@email}{\cvc@email}}%
  \cvc@line{\cvc@phone}{\faIcon{phone}}{\cvc@phone}%
  \cvc@line{\cvc@location}{\faIcon{map-marker-alt}}{\cvc@location}%
  \cvc@line{\cvc@website}{\faIcon{globe}}%
    {\href{https://\cvc@website}{\cvc@website}}%
  \cvc@line{\cvc@linkedin}{\faLinkedin}%
    {\href{https://www.linkedin.com/in/\cvc@linkedin/}{\cvc@linkedin}}%
  \cvc@line{\cvc@github}{\faGithub}%
    {\href{https://github.com/\cvc@github}{\cvc@github}}%
  \cvc@line{\cvc@bitbucket}{\faBitbucket}%
    {\href{https://bitbucket.org/\cvc@bitbucket/workspace/overview}{\cvc@bitbucket}}%
  \cvc@line{\cvc@scholar}{\faIcon{graduation-cap}}%
    {\href{https://scholar.google.com/citations?user=\cvc@scholar}{Google Scholar}}%
  \cvc@line{\cvc@orcid}{\faIcon{orcid}}%
    {\href{https://orcid.org/\cvc@orcid}{\cvc@orcid}}%
}

% -----------------------------------------------------------------------------
% Helpers
% -----------------------------------------------------------------------------
\newcommand{\cvhref}[2]{\href{#1}{#2}}
\newcommand{\cvdateline}[1]{%
  \hfill\mbox{\textcolor{cvdeep}{\small #1}}%
}
\newcommand{\cvlocationline}[1]{%
  \hfill\mbox{\textcolor{cvlight}{\small #1}}%
}
\newcommand{\cvsubline}[1]{\textcolor{cvsecondary}{\small #1}}
\newcommand{\cvtopicline}[1]{\textcolor{cvsecondary}{\small\textit{Topics: #1}}}
\newcommand{\cventryiconsize}{\small}
% max characters per title line (the main column is narrower than a full page)
\newcommand{\cventrytitlemax}{50}

% -----------------------------------------------------------------------------
% Title splitter (long titles wrap onto extra bold lines)
% -----------------------------------------------------------------------------
\ExplSyntaxOn
\tl_new:N \cve@first
\tl_new:N \cve@rest
\seq_new:N \l__cve_words_seq
\seq_new:N \l__cve_lines_seq
\tl_new:N \l__cve_line_tl
\int_new:N \l__cve_len_int

\cs_new_protected:Npn \cvesplittitle #1 #2
  {
    \tl_clear:N \cve@first
    \tl_clear:N \cve@rest
    \tl_clear:N \l__cve_line_tl
    \int_zero:N \l__cve_len_int
    \seq_clear:N \l__cve_lines_seq
    \seq_set_split:NnV \l__cve_words_seq { ~ } #1
    \seq_map_inline:Nn \l__cve_words_seq
      {
        \tl_if_empty:NTF \l__cve_line_tl
          {
            \tl_set:Nn \l__cve_line_tl {##1}
            \int_set:Nn \l__cve_len_int { \str_count:n {##1} }
          }
          {
            \int_compare:nNnTF
              { \l__cve_len_int + 1 + \str_count:n {##1} } > {#2}
              {
                \seq_put_right:NV \l__cve_lines_seq \l__cve_line_tl
                \tl_set:Nn \l__cve_line_tl {##1}
                \int_set:Nn \l__cve_len_int { \str_count:n {##1} }
              }
              {
                \tl_put_right:Nn \l__cve_line_tl { ~ ##1 }
                \int_add:Nn \l__cve_len_int { 1 + \str_count:n {##1} }
              }
          }
      }
    \seq_put_right:NV \l__cve_lines_seq \l__cve_line_tl
    % right icons go after the last title line
    \tl_if_empty:NF \cve@righticons
      {
        \seq_pop_right:NN \l__cve_lines_seq \l_tmpa_tl
        \tl_put_right:Nn \l_tmpa_tl { \cventryiconsright { \cve@righticons } }
        \seq_put_right:NV \l__cve_lines_seq \l_tmpa_tl
      }
    % first line goes beside the date/location, the others become \cve@rest
    \seq_pop_left:NN \l__cve_lines_seq \cve@first
    \seq_map_inline:Nn \l__cve_lines_seq
      { \tl_put_right:Nn \cve@rest {\noindent\textbf{##1}\par} }
  }
\ExplSyntaxOff

% -----------------------------------------------------------------------------
% \cventry — general entry for the main column
% Usage:
% \cventry{
%   title      : first line in bold
%   subtitle   : second line in normal text
%   body       : line in grey
%   bodytwo    : second line in grey
%   date       : single date or range (alias: dates)
%   location   : appears after the date as "date | location" (top right)
%   lefticons  : fontawesome5 icon names left of the title (alias: icon)
%   righticons : fontawesome5 icon names right of the title
%   website, github, bitbucket, article, docs : URLs, shown as icon links
%   items      : e.g. \begin{itemize}\item ...\end{itemize}
% }
% -----------------------------------------------------------------------------
\ExplSyntaxOn
\keys_define:nn { cventry }
  {
    title       .code:n = { \def\cve@title{#1} },
    subtitle    .code:n = { \def\cve@subtitle{#1} },
    body        .code:n = { \def\cve@body{#1} },
    bodytwo     .code:n = { \def\cve@bodytwo{#1} },
    date        .code:n = { \def\cve@date{#1} },
    dates       .code:n = { \def\cve@date{#1} },
    location    .code:n = { \def\cve@location{#1} },
    lefticons   .code:n = { \def\cve@lefticons{#1} },
    icon        .code:n = { \def\cve@lefticons{#1} },
    righticons  .code:n = { \def\cve@righticons{#1} },
    items       .code:n = { \def\cve@items{#1} },
    website     .code:n = { \def\cve@website{#1} },
    bitbucket   .code:n = { \def\cve@bitbucket{#1} },
    github      .code:n = { \def\cve@github{#1} },
    article     .code:n = { \def\cve@article{#1} },
    docs        .code:n = { \def\cve@docs{#1} },
  }
\cs_new_eq:NN \cventrysetkeys \keys_set:nn

\clist_new:N \l__cve_icons_clist
\NewDocumentCommand{\cventryiconsleft}{m}
  {
    \clist_set:Nx \l__cve_icons_clist {#1}
    \clist_map_inline:Nn \l__cve_icons_clist
      { {\cventryiconsize\faIcon{##1}}\enspace }
  }
\NewDocumentCommand{\cventryiconsright}{m}
  {
    \clist_set:Nx \l__cve_icons_clist {#1}
    \clist_map_inline:Nn \l__cve_icons_clist
      { \enspace{\cventryiconsize\faIcon{##1}} }
  }
\ExplSyntaxOff

% links at the bottom: \cve@link{icon}{label}{macro holding the URL}
\newif\ifcve@firstlink
\newif\ifcve@locpending %for location

\newcommand{\cve@link}[3]{%
  \ifdefempty{#3}{}{%
    \ifcve@firstlink
      \cve@firstlinkfalse
      \par\noindent
    \else
      \ \textbar\ %
    \fi
    \cvhref{#3}{\faIcon{#1}\enspace #2}%
  }%
}

\NewDocumentCommand{\cventry}{+m}{%
  % reset every field so values don't leak between entries
  \def\cve@title{}\def\cve@subtitle{}\def\cve@lefticons{}%
  \def\cve@righticons{}\def\cve@date{}\def\cve@location{}%
  \def\cve@body{}\def\cve@bodytwo{}\def\cve@items{}%
  \def\cve@website{}\def\cve@bitbucket{}\def\cve@github{}%
  \def\cve@article{}\def\cve@docs{}%
  \cventrysetkeys{cventry}{#1}%
  \par\vspace{\cvitemsep}%
  % title (split to avoid overlapping the date), icons if requested
  \cvesplittitle\cve@title{\cventrytitlemax}%
  \noindent
  \ifdefempty{\cve@lefticons}{}{\cventryiconsleft{\cve@lefticons}}%
    \textbf{\cve@first}\cvdateline{\cve@date}\par
  \cve@rest
  % location is placed once: beside the subtitle, else beside the body
  \cve@locpendingfalse
  \ifdefempty{\cve@location}{}{\cve@locpendingtrue}%
  \ifdefempty{\cve@subtitle}{}{%
    \cve@subtitle
    \ifcve@locpending
      \cvlocationline{\cve@location}\cve@locpendingfalse
    \fi
    \par
  }%
  \ifdefempty{\cve@body}{}{%
    \cvsubline{\cve@body}%
    \ifcve@locpending
      \cvlocationline{\cve@location}\cve@locpendingfalse
    \fi
    \par
  }%
  \ifdefempty{\cve@bodytwo}{}{\cvsubline{\cve@bodytwo}\par}%
  % fallback: location given but no subtitle or body
  \ifcve@locpending
    \cvlocationline{\cve@location}\par
  \fi
  \ifdefempty{\cve@items}{}{\vspace{0.1em}\cve@items}%
  \cve@firstlinktrue
  \cve@link{globe}{Website}{\cve@website}%
  \cve@link{bitbucket}{Bitbucket}{\cve@bitbucket}%
  \cve@link{github}{GitHub}{\cve@github}%
  \cve@link{file-alt}{Article}{\cve@article}%
  \cve@link{book}{Docs}{\cve@docs}%
  \ifcve@firstlink\else\par\fi
  \par\vspace{\cvitemsep}%
}
