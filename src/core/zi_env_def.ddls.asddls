@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Environment Definition (Interface View)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_ENV_DEF
  as select from zenvdef
{
  key env_id      as EnvId,

      description as Description,
      next_sys    as NextSys,
      is_active   as IsActive
}
