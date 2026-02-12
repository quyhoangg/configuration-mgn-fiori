@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View - Safety Stock'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_MM_SAFE_STOCK
  as select from zmmsafestock
{
  key item_id    as ItemId,
      req_id     as ReqId,
      env_id     as EnvId,
      plant_id   as PlantId,
      mat_group  as MatGroup,
      min_qty    as MinQty,
      version_no as VersionNo,
      created_by as CreatedBy,
      created_at as CreatedAt,
      changed_by as ChangedBy,
      changed_at as ChangedAt
}
