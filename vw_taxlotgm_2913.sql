 /*Adding some comments to test this process with github*/
 /**/
 WITH property AS (
         SELECT DISTINCT ON (app_vproperty.mapnumber) app_vproperty.mapnumber,
            app_vproperty.propertynumbersearch,
            app_vproperty.propertyid
           FROM crs.app_vproperty
          WHERE app_vproperty.propertynumber::text ~~ 'R%'::text AND app_vproperty.mapnumber::text <> '00-00-00-00-00000-00'::text
          ORDER BY app_vproperty.mapnumber, app_vproperty.propertyid
        ), powner AS (
         SELECT DISTINCT ON (vwpropertyowner.propertyid) vwpropertyowner.propertyid,
            vwpropertyowner.partyid,
            vwpropertyowner.ishiddenonwebsite,
            vwpropertyowner.partyname AS ownname
           FROM crs.vwpropertyowner
          WHERE vwpropertyowner.ownerquickrefid::text ~~ 'R%'::text
          ORDER BY vwpropertyowner.propertyid
        ), situs AS (
         SELECT DISTINCT app_vproperty.mapnumber,
            app_vpropertysitusaddr.fmtpropertyfulladdress
           FROM crs.app_vpropertysitusaddr
             JOIN crs.app_vproperty ON app_vpropertysitusaddr.propertyid = app_vproperty.propertyid
        ), situsall AS (
         SELECT situs.mapnumber,
            string_agg(situs.fmtpropertyfulladdress::text, '; '::text) AS situsall
           FROM situs
          GROUP BY situs.mapnumber
        )
 SELECT vw_taxlot_2913.ogc_fid,
    vw_taxlot_2913.imagekey,
    vw_taxlot_2913.taxlotacre,
    vw_taxlot_2913.mapacres,
    vw_taxlot_2913.maptaxlot AS parcelid,
    vw_taxlot_2913.ormapfield,
    vw_taxlot_2913.shape,
    property.propertynumbersearch AS propertyid,
        CASE powner.ishiddenonwebsite
            WHEN '1'::text THEN 'PROPERTY TAXPAYER'::character varying
            WHEN '0'::text THEN powner.ownname
            ELSE NULL::character varying
        END AS ownname,
        CASE powner.ishiddenonwebsite
            WHEN '1'::text THEN ''::character varying
            WHEN '0'::text THEN vwpartyaddress.address1
            ELSE NULL::character varying
        END AS address1,
        CASE powner.ishiddenonwebsite
            WHEN '1'::text THEN ''::character varying
            WHEN '0'::text THEN vwpartyaddress.address2
            ELSE NULL::character varying
        END AS address2,
        CASE powner.ishiddenonwebsite
            WHEN '1'::text THEN ''::character varying
            WHEN '0'::text THEN vwpartyaddress.address3
            ELSE NULL::character varying
        END AS address3,
        CASE powner.ishiddenonwebsite
            WHEN '1'::text THEN ''::character varying
            WHEN '0'::text THEN concat(vwpartyaddress.city, ', ', vwpartyaddress.state, ' ', vwpartyaddress.zip)::character varying
            ELSE NULL::character varying
        END AS ctystzip,
    situsall.situsall,
    concat('https://maps.co.lincoln.or.us/?service=search-Taxlots&field:parcelid=', vw_taxlot_2913.maptaxlot) AS gislink
   FROM crs.vw_taxlot_2913
     LEFT JOIN property ON vw_taxlot_2913.maptaxlot::text = property.mapnumber::text
     LEFT JOIN powner ON property.propertyid = powner.propertyid
     LEFT JOIN crs.vwpartyaddress ON powner.partyid = vwpartyaddress.partyid
     LEFT JOIN situsall ON property.mapnumber::text = situsall.mapnumber::text
  WHERE vw_taxlot_2913.maptaxlot::text !~~ '%R%'::text;


