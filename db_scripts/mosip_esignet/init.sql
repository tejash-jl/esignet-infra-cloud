\c mosip_esignet postgres

DROP SCHEMA IF EXISTS esignet CASCADE;
CREATE SCHEMA esignet;
ALTER SCHEMA esignet OWNER TO postgres;
ALTER DATABASE mosip_esignet SET search_path TO esignet,pg_catalog,public;

CREATE TABLE esignet.client_detail(
  id character varying(100) NOT NULL,
  name character varying(256) NOT NULL,
  rp_id character varying(100) NOT NULL,
  logo_uri character varying(2048) NOT NULL,
  redirect_uris character varying NOT NULL,
  claims character varying NOT NULL,
  acr_values character varying NOT NULL,
  public_key character varying NOT NULL,
  grant_types character varying NOT NULL,
  auth_methods character varying NOT NULL,
  status character varying(20) NOT NULL,
  cr_dtimes timestamp NOT NULL,
  upd_dtimes timestamp,
  CONSTRAINT pk_clntdtl_id PRIMARY KEY (id),
  CONSTRAINT uk_clntdtl_key UNIQUE (public_key)
);

create table esignet.consent_detail (
    id UUID NOT NULL,
    client_id VARCHAR NOT NULL,
    psu_token VARCHAR NOT NULL,
    claims VARCHAR NOT NULL,
    authorization_scopes VARCHAR NOT NULL,
    cr_dtimes TIMESTAMP DEFAULT NOW() NOT NULL,
    expire_dtimes TIMESTAMP,
    signature VARCHAR,
    hash VARCHAR,
    accepted_claims VARCHAR,
    permitted_scopes VARCHAR,
    PRIMARY KEY (id),
    CONSTRAINT unique_client_token UNIQUE (client_id, psu_token)
);

CREATE INDEX IF NOT EXISTS idx_consent_psu_client ON esignet.consent_detail(psu_token, client_id);

create table esignet.consent_history (
    id UUID NOT NULL,
    client_id VARCHAR NOT NULL,
    psu_token VARCHAR NOT NULL,
    claims VARCHAR NOT NULL,
    authorization_scopes VARCHAR NOT NULL,
    cr_dtimes TIMESTAMP DEFAULT NOW() NOT NULL,
    expire_dtimes TIMESTAMP,
    signature VARCHAR,
    hash VARCHAR,
    accepted_claims VARCHAR,
    permitted_scopes VARCHAR,
    PRIMARY KEY (id)
);
CREATE INDEX IF NOT EXISTS idx_consent_history_psu_client ON esignet.consent_history(psu_token, client_id);

CREATE TABLE esignet.key_alias(
    id character varying(36) NOT NULL,
    app_id character varying(36) NOT NULL,
    ref_id character varying(128),
    key_gen_dtimes timestamp,
    key_expire_dtimes timestamp,
    status_code character varying(36),
    lang_code character varying(3),
    cr_by character varying(256) NOT NULL,
    cr_dtimes timestamp NOT NULL,
    upd_by character varying(256),
    upd_dtimes timestamp,
    is_deleted boolean DEFAULT FALSE,
    del_dtimes timestamp,
    cert_thumbprint character varying(100),
    uni_ident character varying(50),
    CONSTRAINT pk_keymals_id PRIMARY KEY (id),
    CONSTRAINT uni_ident_const UNIQUE (uni_ident)
);

CREATE TABLE esignet.key_policy_def(
    app_id character varying(36) NOT NULL,
    key_validity_duration smallint,
    is_active boolean NOT NULL,
    pre_expire_days smallint,
    access_allowed character varying(1024),
    cr_by character varying(256) NOT NULL,
    cr_dtimes timestamp NOT NULL,
    upd_by character varying(256),
    upd_dtimes timestamp,
    is_deleted boolean DEFAULT FALSE,
    del_dtimes timestamp,
    CONSTRAINT pk_keypdef_id PRIMARY KEY (app_id)
);

CREATE TABLE esignet.key_store(
  id character varying(36) NOT NULL,
  master_key character varying(36) NOT NULL,
  private_key character varying(2500) NOT NULL,
  certificate_data character varying NOT NULL,
  cr_by character varying(256) NOT NULL,
  cr_dtimes timestamp NOT NULL,
  upd_by character varying(256),
  upd_dtimes timestamp,
  is_deleted boolean DEFAULT FALSE,
  del_dtimes timestamp,
  CONSTRAINT pk_keystr_id PRIMARY KEY (id)
);

CREATE TABLE esignet.public_key_registry(
    id_hash character varying(100) NOT NULL,
    auth_factor character varying(25) NOT NULL,
  psu_token character varying(256) NOT NULL,
  public_key character varying NOT NULL,
  expire_dtimes timestamp NOT NULL,
  wallet_binding_id character varying(256) NOT NULL,
  public_key_hash character varying(100) NOT NULL,
  certificate character varying NOT NULL,
  cr_dtimes timestamp NOT NULL,
  thumbprint character varying NOT NULL,
  CONSTRAINT pk_public_key_registry PRIMARY KEY (id_hash, auth_factor)
);


INSERT INTO esignet.KEY_POLICY_DEF(APP_ID,KEY_VALIDITY_DURATION,PRE_EXPIRE_DAYS,ACCESS_ALLOWED,IS_ACTIVE,CR_BY,CR_DTIMES) VALUES('ROOT', 2920, 1125, 'NA', true, 'mosipadmin', now());
INSERT INTO esignet.KEY_POLICY_DEF(APP_ID,KEY_VALIDITY_DURATION,PRE_EXPIRE_DAYS,ACCESS_ALLOWED,IS_ACTIVE,CR_BY,CR_DTIMES) VALUES('OIDC_SERVICE', 1095, 50, 'NA', true, 'mosipadmin', now());
INSERT INTO esignet.KEY_POLICY_DEF(APP_ID,KEY_VALIDITY_DURATION,PRE_EXPIRE_DAYS,ACCESS_ALLOWED,IS_ACTIVE,CR_BY,CR_DTIMES) VALUES('OIDC_PARTNER', 1095, 50, 'NA', true, 'mosipadmin', now());
INSERT INTO esignet.KEY_POLICY_DEF(APP_ID,KEY_VALIDITY_DURATION,PRE_EXPIRE_DAYS,ACCESS_ALLOWED,IS_ACTIVE,CR_BY,CR_DTIMES) VALUES('BINDING_SERVICE', 1095, 50, 'NA', true, 'mosipadmin', now());
INSERT INTO esignet.KEY_POLICY_DEF(APP_ID,KEY_VALIDITY_DURATION,PRE_EXPIRE_DAYS,ACCESS_ALLOWED,IS_ACTIVE,CR_BY,CR_DTIMES) VALUES('MOCK_BINDING_SERVICE', 1095, 50, 'NA', true, 'mosipadmin', now());