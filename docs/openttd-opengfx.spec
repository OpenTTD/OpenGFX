#
# spec file for package openttd-opengfx
#
# Copyright (c) 2012 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

Name:           openttd-opengfx
Version:        0.4.3
Release:        0
%define srcver  %{version}
Summary:        Default baseset graphics for OpenTTD
License:        GPL-2.0
Group:          Amusements/Games/Strategy/Other

Url:            http://dev.openttdcoop.org/projects/opengfx
Source0:        http://bundles.openttdcoop.org/opengfx/releases/%{srcver}/opengfx-%{srcver}-source.tar.gz

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

BuildRequires:  nml >= 0.2.3

%if !0%{?without_gimp}
BuildRequires:  gimp
%endif

Requires:       openttd-data >= 1.2
Provides:       opengfx = %{version}

%description
OpenGFX is an open source graphics base set designed to be used by OpenTTD.

OpenGFX provides a set of free and open source base graphics, and aims to
ensure the best possible out-of-the-box experience with OpenTTD.

%prep
%setup -qn opengfx-%{srcver}-source
%if !0%{?without_gimp}
make maintainer-clean
%endif

%build
make %{?_smp_mflags} _V=

%install
# we need to define version on the install target, else it could conflict with
# possible same named opengfx in $HOME
%define ogfxdir %{_datadir}/openttd/baseset/opengfx-%{version}
make install INSTALL_DIR=%{buildroot}%{ogfxdir} _V=

%check
make check

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%dir %{_datadir}/openttd
%dir %{_datadir}/openttd/baseset
%dir %{ogfxdir}
%doc %{ogfxdir}/changelog.txt
%doc %{ogfxdir}/license.txt
%doc %{ogfxdir}/readme.txt
%{ogfxdir}/ogfx1_base.grf
%{ogfxdir}/ogfxc_arctic.grf
%{ogfxdir}/ogfxe_extra.grf
%{ogfxdir}/ogfxh_tropical.grf
%{ogfxdir}/ogfxi_logos.grf
%{ogfxdir}/ogfxt_toyland.grf
%{ogfxdir}/opengfx.obg

%changelog
