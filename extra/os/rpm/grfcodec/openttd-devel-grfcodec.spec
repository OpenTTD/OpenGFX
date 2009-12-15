# grfcodec to build opengfx

Name:           openttd-devel-grfcodec
Version:        r2247
Release:        1%{?dist}
Summary:        A suite of programs to modify Transport Tycoon Deluxe's GRF files
Group:          Development/Tools
License:        GPLv2+
URL:            http://www.ttdpatch.net/grfcodec/
Source0:        http://binaries.openttd.org/extra/grfcodec/%{version}/grfcodec-%{version}-source.tar.bz2
Patch0:		remove-upx.diff
# Patch from fedoraproject.org (Iain Arnell <iarnell@gmail.com>)
Patch1:		compile.patch

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-buildroot

BuildRequires:  gcc-c++
BuildRequires:  boost-devel

%description
A suite of programs to modify Transport Tycoon Deluxe's GRF files.
This program is needed to de-/encode graphic extenions, which you 
need to build OpenGFX.

%prep
%setup -qn grfcodec-%{version}
%patch0 -p0
%patch1 -p1

%build
make %{?_smp_mflags} SVNVERSION="echo %{version}"

%install
#make install
for file in grfcodec grfdiff grfmerge; do
  strip $file
  install -D -m 755 $file %{buildroot}%{_bindir}/$file
done

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%doc Changelog COPYING grfcodec.txt grftut.txt grf.txt
%{_bindir}/grfcodec
%{_bindir}/grfdiff
%{_bindir}/grfmerge

%changelog
* Thu Dec 10 2009 Marcel Gmür <ammler@openttdcoop.org>- r2247
- upstream update
- rename package to openttd-devel-grfcodec
* Mon Sep 21 2009 Marcel Gmür <ammler@openttdcoop.org>- r2212
- compile patch (from fedoraproject.org)
- remove upx (patch)
- using make install
- requires gcc-c++
* Sun May 03 2009 Iain Arnell <iarnell@gmail.com> 0.9.11-0.2.r2111
- fix license tag (GPLv2+)
- don't pass -O3 to gcc
- doesn't BR subversion
* Sat May 02 2009 Iain Arnell <iarnell@gmail.com> 0.9.11-0.1.r2111
- initial release

