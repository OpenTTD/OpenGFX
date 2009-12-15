
Name:           openttd-data-opengfx
Version:        0.2.0
Release:        1%{?dist}
Summary:        OpenGFX replacement graphics for OpenTTD

Group:          Amusements/Games
License:        GPLv2
URL:            http://dev.openttdcoop.org/projects/opengfx
Source0:        http://bundles.openttdcoop.org/opengfx/releases/opengfx-%{version}-source.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildArch:      noarch

BuildRequires:  openttd-devel-grfcodec
BuildRequires:  openttd-devel-nforenum
Requires:	openttd-data

Provides:       opengfx

%description
The ultimate aim of this project is to have a full replacement set of graphics,
so that OpenTTD can be distributed freely without the need of the copyrighted
graphics from the original game.

For OpenTTD versions <0.8, it needs also a dummy file sample.cat to work.

%prep
%setup -qn opengfx-%{version}-source

%build
# special target for releases
make %{?_smp_mflags}

%install
# opengfx has a different target for release install:
make install INSTALLDIR=%{buildroot}%{_datadir}/openttd/data

# OpenGFX doesn't have a sound file and so this is required
# otherwise OpenTTD refuses to start
touch %{buildroot}%{_datadir}/openttd/data/sample.cat

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc docs/*.txt
%dir %{_datadir}/openttd
%dir %{_datadir}/openttd/data
%{_datadir}/openttd/data/opengfx-%{version}.tar
# dummy sample.cat for openttd < 0.8
%{_datadir}/openttd/data/sample.cat

%changelog
* Thu Dec 10 2009 Marcel Gmür <ammler@openttdcoop.or> - 0.2.0
- upstream update 0.2.0
- package rename to openttd-data-opengfx
- BuildRequirment openttd-data removed
* Mon Sep 21 2009 Marcel Gmür <ammler@openttdcoop.org> - 0.1.1
- docs in unix format now
- release targets for make
- no subfolder games from datadir
* Fri Sep 18 2009 Marcel Gmür <ammler@openttdcoop.org> - 0.1.0-alpha6
- added nforenum
- openttd is required for building
* Sun Aug 23 2009 Felix Kaechele <heffer@fedoraproject.org> - 0.1.0-0.1.alpha6
- new upstream release
* Sat Jul 25 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0-0.5.alpha4.2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild
* Thu May 28 2009 Felix Kaechele <heffer@fedoraproject.org> - 0-0.4.alpha4.2
- added md5 check
* Tue Apr 14 2009 Felix Kaechele <heffer@fedoraproject.org> - 0-0.3.alpha4.2
- now compiles from source
* Sun Mar 29 2009 Felix Kaechele <heffer@fedoraproject.org> - 0-0.2.alpha4.2
- improved macro usage
- touch sample.cat
* Sat Mar 21 2009 Felix Kaechele <heffer@fedoraproject.org> - 0-0.1.alpha4.2
- initial build

