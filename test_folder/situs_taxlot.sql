 SELECT app_vpropertysitusaddr.ogc_fid,
    app_vpropertysitusaddr.propertyaddressid,
    app_vpropertysitusaddr.propertyid,
    app_vpropertysitusaddr.fmtpropertyfulladdress,
    app_vproperty.propertynumbersearch,
    app_vproperty.mapnumber
   FROM crs.app_vpropertysitusaddr
     JOIN crs.app_vproperty ON app_vproperty.propertyid = app_vpropertysitusaddr.propertyid
  ORDER BY app_vproperty.mapnumber;