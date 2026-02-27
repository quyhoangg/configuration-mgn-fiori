@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Config Catalog Projection'
@Metadata.allowExtensions: true

define root view entity ZC_CONF_CATALOG
  provider contract transactional_query
  as projection on ZI_CONF_CATALOG
{
  key ConfId,
      ModuleId,
      ConfName,
      ConfType,
      Description,
      TargetCds,
      IsActive,
      CreatedBy,
      CreatedAt,
      ChangedBy,
      ChangedAt,

      _FieldDef
}
