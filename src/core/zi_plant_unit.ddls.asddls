@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View - Plant Unit'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_PLANT_UNIT
  as select from zplantunit
{
  key plant_id     as PlantId,
      plant_type   as PlantType,
      description  as Description,
      parent_org   as ParentOrg
}
