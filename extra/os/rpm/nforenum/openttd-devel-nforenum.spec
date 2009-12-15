Name:           openttd-devel-nforenum
Version:        r2274
Release:        1%{?dist}
Summary:        A format correcter and linter for the NFO language
Group:          Development/Tools
License:        GPLv2+
URL:            http://users.tt-forums.net/dalestan/nforenum/

Source0:        nforenum-%{version}-source.tar.bz2
# fix compile from fedoraproject.org (Felix Kaechele <heffer@fedoraproject.org>)
Patch0:		nforenum-gcc44.patch

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-buildroot

BuildRequires:  gcc-c++
%if 0%{?centos_version} > 501 || 0%{?fedora_version} > 10 || 0%{?mandriva_version} > 2008 || 0%{?rhel_version} > 501 || 0%{?suse_version} > 1100
BuildRequires:  boost-devel
%else
BuildRequires:  openttd-devel-nforenum-boost
%endif

%description
A format correcter and linter for the NFO language. NFO is used for 
graphic extensions of the Transport Tycoon games TTDPatch and 
OpenTTD, this rpm is dedicated to OpenGFX, the free replacement to
make it possible using OpenTTD without the need of the original
graphics.

%prep
%setup -qn nforenum-%{version}
#%patch0 -p0

%build
make %{?_smp_mflags} SVNVERSION="echo %{version}"
strip renum

%install
install -D -m 755 renum %{buildroot}%{_bindir}/renum

%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
%doc CHANGELOG.txt COPYING.txt TODO.txt
%doc doc/
%{_bindir}/*


%changelog
* Thu Dec 10 2009 Marcel Gmür <ammler@openttdcoop.org>  r2274
- upstream update r2274
- rename package to openttd-devel-nforenum
* Mon Sep 21 2009 Marcel Gmür <ammler@openttdcoop.org> - r2215
- using binaries.openttd.org as source
- requires gcc-c++ 
* Sun Sep 06 2009 Felix Kaechele <heffer@fedoraproject.org> - 3.4.7-0.2.r2184
- incorporated changes as suggested in #519118
* Mon Aug 24 2009 Felix Kaechele <heffer@fedoraproject.org> - 3.4.7-0.1.r2184
- initial package

