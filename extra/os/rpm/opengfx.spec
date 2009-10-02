# opengfx \o/


Name:           opengfx
Version:        0.1.1
Release:        1%{?dist}
Summary:        OpenGFX replacement graphics for OpenTTD

Group:          Amusements/Games
License:        GPLv2
URL:            http://dev.openttdcoop.org/projects/opengfx
Source0:        http://bundles.openttdcoop.org/opengfx/releases/%{name}-%{version}-source.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-buildroot
BuildArch:      noarch

BuildRequires:  grfcodec
BuildRequires:	openttd
Requires:       openttd
#nforenum is very hard to build on the older distros, so we skip it there...
%if 0%{?centos_version} > 501 || 0%{?fedora_version} > 10 || 0%{?mandriva_version} > 2008 || 0%{?rhel_version} > 501 || 0%{?suse_version} > 1100 
BuildRequires:  nforenum
%endif

%description
The ultimate aim of this project is to have a full replacement set of graphics,
so that OpenTTD can be distributed freely without the need of the copyrighted
graphics from the original game.

For OpenTTD versions <0.8, it needs also a dummy file sample.cat to work.

%prep
%setup -q -n %{name}-%{version}-source

%build
# special target for releases
make release %{?_smp_mflags}

%install
# opengfx has a different target for release install:
make release-install INSTALLDIR=%{buildroot}%{_datadir}/openttd/data

# OpenGFX doesn't have a sound file and so this is required
# otherwise OpenTTD refuses to start
touch %{buildroot}%{_datadir}/openttd/data/sample.cat

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc docs/*.txt
%{_datadir}/openttd/data/*


%changelog
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

