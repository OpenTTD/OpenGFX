#!/bin/bash

function get_langline() {
	id=`cat $1 | grep 'grflangid' | cut -c13-16`
	text=`cat $1 | grep 'STR_GENERAL_DESC' | cut -d: -f2-`
	langcode=""
	case "$id" in
		"0x01" ) langcode="en_GB";;
		"0x02" ) langcode="de_DE";;
		"0x1b" ) langcode="af_ZA";;
		"0x14" ) langcode="ar_EG";;
		"0x21" ) langcode="eu_ES";;
		"0x10" ) langcode="be_BY";;
		"0x37" ) langcode="pt_BR";;
		"0x18" ) langcode="bg_BG";;
		"0x22" ) langcode="ca_ES";;
		"0x0B" ) langcode="cv_RU";;
		"0x38" ) langcode="hr_HR";;
		"0x15" ) langcode="cs_CZ";;
		"0x2d" ) langcode="da_DK";;
		"0x1f" ) langcode="nl_NL";;
		"0x3D" ) langcode="en_AU";;
		"0x00" ) langcode="en_US";;
		"0x05" ) langcode="eo_EO";;
		"0x34" ) langcode="et_EE";;
		"0x12" ) langcode="fo_FO";;
		"0x35" ) langcode="fi_FI";;
		"0x03" ) langcode="fr_FR";;
		"0x32" ) langcode="fy_NL";;
		"0x31" ) langcode="gl_ES";;
		"0x13" ) langcode="gd_GB";;
		"0x1e" ) langcode="el_GR";;
		"0x61" ) langcode="he_IL";;
		"0x24" ) langcode="hu_HU";;
		"0x29" ) langcode="is_IS";;
		"0x06" ) langcode="io_IO";;
		"0x5a" ) langcode="id_ID";;
		"0x08" ) langcode="ga_IE";;
		"0x27" ) langcode="it_IT";;
		"0x39" ) langcode="ja_JP";;
		"0x3a" ) langcode="ko_KR";;
		"0x2a" ) langcode="lv_LV";;
		"0x2b" ) langcode="lt_LT";;
		"0x23" ) langcode="lb_LU";;
		"0x26" ) langcode="mk_MK";;
		"0x3c" ) langcode="ms_MY";;
		"0x09" ) langcode="mt_MT";;
		"0x11" ) langcode="mr_IN";;
		"0x2f" ) langcode="nb_NO";;
		"0x0e" ) langcode="nn_NO";;
		"0x62" ) langcode="fa_IR";;
		"0x30" ) langcode="pl_PL";;
		"0x36" ) langcode="pt_PT";;
		"0x28" ) langcode="ro_RO";;
		"0x07" ) langcode="ru_RU";;
		"0x0d" ) langcode="sr_RS";;
		"0x56" ) langcode="zh_CN";;
		"0x16" ) langcode="sk_SK";;
		"0x2c" ) langcode="sl_SI";;
		"0x04" ) langcode="es_ES";;
		"0x2e" ) langcode="sv_SE";;
		"0x0a" ) langcode="ta_IN";;
		"0x42" ) langcode="th_TH";;
		"0x0c" ) langcode="zh_TW";;
		"0x3e" ) langcode="tr_TR";;
		"0x33" ) langcode="uk_UA";;
		"0x54" ) langcode="vi_VN";;
		"0x0f" ) langcode="cy_GB";;
		"0x5c" ) langcode="ur_PK";;
	esac

	# special treatment for the default language, en_GB
	if [ "$langcode" == "en_GB" ]; then
		generalline="description = $text"
	fi
	line="description.$langcode = $text"
}

# Obtain list of lang files
lang_files="`ls lang/*.lng`"

# Loop over language files
for i in $lang_files; do
	# echo "Processing: $i"
	get_langline $i

	# make sure that we only write sensible stuff
	if [ "$langcode" != "" ] && [ "$text" != "" ]; then
		echo "$line"
	fi
done
echo "$generalline"

# echo "$1 has language $langcode."