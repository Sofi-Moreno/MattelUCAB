CREATE TABLE lugar (
    lg_id     INTEGER  NOT NULL , 
    lg_nombre VARCHAR(255) NOT NULL , 
    lg_tipo   VARCHAR(255) NOT NULL , 
    fk_lg_lg  INTEGER,
    CONSTRAINT lugar_PK PRIMARY KEY ( lg_id ),
    CONSTRAINT lugar_lugar_FK FOREIGN KEY (fk_lg_lg) 
    REFERENCES lugar (lg_id),
    CONSTRAINT lugar_tipo_check CHECK(lg_tipo IN
    ('Continente', 
    'País', 
    'Estado', 
    'Municipio', 
    'Parroquia'))
);

CREATE TABLE moneda (
    m_id      INTEGER NOT NULL , 
    m_nombre  VARCHAR(255) NOT NULL , 
    m_simbolo CHAR(5) NOT NULL , 
    m_activa  BOOLEAN  NOT NULL DEFAULT true,
    CONSTRAINT moneda_PK PRIMARY KEY ( m_id )
);

CREATE TABLE beneficio (
    bnf_id               INTEGER  NOT NULL , 
    bnf_nombre           VARCHAR(255) NOT NULL , 
    bnf_tipo             VARCHAR(255) NOT NULL , 
    bnf_naturaleza       VARCHAR(255) NOT NULL , 
    bnf_tipo_calculo     VARCHAR(255) NOT NULL , 
    bnf_monto_referencia NUMERIC  NOT NULL,
    CONSTRAINT beneficio_PK PRIMARY KEY ( bnf_id ),
    CONSTRAINT tipo_beneficio CHECK(bnf_tipo IN('Recargo', 'Prima Salarial', 'Bono', 'Comisión', 'Regalia')),
    CONSTRAINT tipo_naturaleza CHECK(bnf_naturaleza IN('Fijo','Variable')),
    CONSTRAINT tipo_calculo CHECK(bnf_tipo_calculo IN('Monto', 'Porcentaje'))
);

CREATE TABLE horario (
    hrr_id           INTEGER  NOT NULL , 
    hrr_hora_entrada TIME  NOT NULL , 
    hrr_hora_salida  TIME  NOT NULL,
    CONSTRAINT horario_PK PRIMARY KEY ( hrr_id )
);

CREATE TABLE departamento (
    dptmt_id          INTEGER  NOT NULL , 
    dptmt_nombre      VARCHAR(255) NOT NULL , 
    dptmt_descripcion VARCHAR(255) NOT NULL,
    CONSTRAINT departamento_PK PRIMARY KEY ( dptmt_id )
);

CREATE TABLE era_historica (
    eh_id           INTEGER  NOT NULL , 
    eh_nombre       VARCHAR(255) NOT NULL , 
    eh_fecha_inicio DATE  NOT NULL , 
    eh_fecha_fin    DATE  NOT NULL,
    CONSTRAINT era_historica_PK PRIMARY KEY ( eh_id )
);

CREATE TABLE tipo_cuerpo (
    tc_id          INTEGER  NOT NULL , 
    tc_nombre      VARCHAR(255) NOT NULL , 
    tc_ano_patente DATE  NOT NULL , 
    tc_descripcion VARCHAR(255) NOT NULL,
    CONSTRAINT tipo_cuerpo_PK PRIMARY KEY ( tc_id )
);

CREATE TABLE clasificacion_exclusividad (
    ce_id              INTEGER  NOT NULL , 
    ce_nombre          VARCHAR(255) NOT NULL , 
    ce_limite_unidades INTEGER  NOT NULL , 
    ce_nivel_acceso    VARCHAR(255) NOT NULL , 
    ce_descripcion     VARCHAR(255) NOT NULL,
    CONSTRAINT clasificacion_exclusividad_PK PRIMARY KEY ( ce_id ),
    CONSTRAINT nivel_acceso_check CHECK(ce_nivel_acceso IN('Sin Membresía','Gold','Platinum'))
);

CREATE TABLE color (
    cl_id            INTEGER  NOT NULL , 
    cl_nombre        VARCHAR(255) NOT NULL , 
    cl_codigo_hex    VARCHAR(255) NOT NULL , 
    cl_clasificación VARCHAR(255) NOT NULL,
    CONSTRAINT color_PK PRIMARY KEY ( cl_id )
);

CREATE TABLE profesion (
    pfs_id          INTEGER  NOT NULL , 
    pfs_nombre      VARCHAR(255) NOT NULL , 
    pfs_descripcion VARCHAR(255) NOT NULL,
    CONSTRAINT profesion_PK PRIMARY KEY ( pfs_id )
);

CREATE TABLE tipo_material (
    tm_id          INTEGER  NOT NULL , 
    tm_nombre      VARCHAR(255) NOT NULL , 
    tm_descripcion VARCHAR(255) NOT NULL,
    CONSTRAINT tipo_material_PK PRIMARY KEY ( tm_id )
);

CREATE TABLE membresia (
    mbs_id           INTEGER  NOT NULL, 
    mbs_nombre       VARCHAR(255) NOT NULL, 
    mbs_descripcion  VARCHAR(255) NOT NULL, 
    mbs_early_access BOOLEAN  NOT NULL,
    CONSTRAINT membresia_PK PRIMARY KEY ( mbs_id )
);

CREATE TABLE molde (
    md_id          INTEGER  NOT NULL , 
    md_nombre      VARCHAR(255) NOT NULL , 
    md_ano_patente DATE  NOT NULL , 
    md_descripcion VARCHAR(255) NOT NULL,
    CONSTRAINT molde_PK PRIMARY KEY ( md_id )
);

CREATE TABLE pieza (
    pz_id     INTEGER  NOT NULL , 
    pz_nombre VARCHAR(255) NOT NULL,
    CONSTRAINT pieza_PK PRIMARY KEY ( pz_id )
);

CREATE TABLE operacion_catalogo (
    octlg_id          INTEGER  NOT NULL , 
    octlg_nombre      VARCHAR(255) NOT NULL , 
    octlg_descripcion VARCHAR(255) NOT NULL , 
    octlg_tipo        VARCHAR(255) NOT NULL,
    CONSTRAINT operacion_catalogo_PK PRIMARY KEY ( octlg_id ),
    CONSTRAINT tipo_operacion_check CHECK(octlg_tipo IN('Producción','Prueba'))
);

CREATE TABLE rol (
    r_id          INTEGER  NOT NULL , 
    r_nombre      VARCHAR(255) NOT NULL , 
    r_descripcion VARCHAR(255) NOT NULL,
    CONSTRAINT rol_PK PRIMARY KEY ( r_id )
);

CREATE TABLE permiso (
    pms_id     INTEGER  NOT NULL , 
    pms_nombre VARCHAR(255) NOT NULL , 
    pms_modulo VARCHAR(255) NOT NULL,
    CONSTRAINT permiso_PK PRIMARY KEY ( pms_id )
);

CREATE TABLE transporte (
    tpt_id          INTEGER  NOT NULL , 
    tpt_nombre      VARCHAR(255) NOT NULL , 
    tpt_descripcion VARCHAR(255) NOT NULL , 
    tpt_tipo        VARCHAR(255) NOT NULL,
    CONSTRAINT transporte_PK PRIMARY KEY ( tpt_id ),
    CONSTRAINT tipo_transporte_check CHECK(tpt_tipo IN('Carga', 'Courier'))
);

CREATE TABLE historico_tasa_cambio (
    htc_id                INTEGER  NOT NULL , 
    htc_fecha_hora_inicio TIMESTAMP  NOT NULL , 
    htc_fecha_hora_fin    TIMESTAMP  NOT NULL , 
    htc_tasa              NUMERIC  NOT NULL , 
    fk_m_htc_1            INTEGER NOT NULL , 
    CONSTRAINT historico_tasa_cambio_PK PRIMARY KEY 
    ( htc_id,
      fk_m_htc_1
    ),
    CONSTRAINT historico_tasa_cambio_moneda_FK FOREIGN KEY (fk_m_htc_1) 
    REFERENCES moneda (m_id)

);

CREATE TABLE rol_permiso (
    fk_r_rp   INTEGER  NOT NULL , 
    fk_pms_rp INTEGER  NOT NULL,
    CONSTRAINT rol_permiso_PK PRIMARY KEY ( fk_r_rp, fk_pms_rp ),
    CONSTRAINT rol_permiso_permiso_FK FOREIGN KEY (fk_pms_rp) 
    REFERENCES permiso (pms_id),
    CONSTRAINT rol_permiso_rol_FK FOREIGN KEY (fk_r_rp) 
    REFERENCES rol (r_id)
);

CREATE TABLE cargo (
    cg_id             INTEGER  NOT NULL , 
    cg_nombre         VARCHAR(255) NOT NULL , 
    cg_sueldo_base_us NUMERIC  NOT NULL , 
    fk_dptmt_cg       INTEGER  NOT NULL,
    CONSTRAINT cargo_PK PRIMARY KEY ( cg_id ),
    CONSTRAINT cargo_departamento_FK FOREIGN KEY (fk_dptmt_cg) 
    REFERENCES departamento (dptmt_id)
);

CREATE TABLE persona_natural (
    pn_id               INTEGER  NOT NULL , 
    pn_primer_nombre    VARCHAR(255) NOT NULL , 
    pn_segundo_nombre   VARCHAR(255) , 
    pn_primer_apellido  VARCHAR(255) NOT NULL , 
    pn_segundo_apellido VARCHAR(255) , 
    pn_telefono         VARCHAR(255) NOT NULL , 
    pn_correo           VARCHAR(255) NOT NULL , 
    pn_direccion        VARCHAR(255) NOT NULL , 
    pn_cedula           VARCHAR(255) NOT NULL , 
    pn_fecha_nacimiento DATE  NOT NULL , 
    pn_rif              VARCHAR(255) NOT NULL ,
    pn_tipo             VARCHAR(255) NOT NULL , 
    fk_mbs_pn           INTEGER,  
    fk_lg_pn            INTEGER  NOT NULL,
    CONSTRAINT persona_natural_PK PRIMARY KEY ( pn_id ),
    CONSTRAINT persona_natural_membresia_FK FOREIGN KEY (fk_mbs_pn) 
    REFERENCES membresia (mbs_id),
    CONSTRAINT pn_tipo_check CHECK(pn_tipo IN('Normal','VIP')),
    CONSTRAINT persona_natural_lugar_FK FOREIGN KEY (fk_lg_pn) 
    REFERENCES lugar (lg_id)
);

CREATE TABLE fabrica (
    fbc_id        INTEGER  NOT NULL , 
    fbc_nombre    VARCHAR(255) NOT NULL , 
    fbc_direccion VARCHAR(255) NOT NULL , 
    fbc_tipo      VARCHAR(255) NOT NULL , 
    fk_lg_fbc   INTEGER  NOT NULL,
    CONSTRAINT fabrica_PK PRIMARY KEY ( fbc_id ),
    CONSTRAINT fabrica_lugar_FK FOREIGN KEY (fk_lg_fbc) 
    REFERENCES lugar (lg_id),
    CONSTRAINT fabrica_tipo_check CHECK(fbc_tipo IN('Fabrica','Hub'))
);

CREATE TABLE materia_prima (
    mp_id            INTEGER  NOT NULL , 
    mp_nombre        VARCHAR(255) NOT NULL , 
    mp_unidad_medida VARCHAR(255) NOT NULL , 
    mp_descripcion   VARCHAR(255) NOT NULL , 
    fk_tm_mp         INTEGER  NOT NULL,
    CONSTRAINT materia_prima_PK PRIMARY KEY ( mp_id ),
    CONSTRAINT materia_prima_tipo_material_FK FOREIGN KEY (fk_tm_mp) 
    REFERENCES tipo_material (tm_id)
);

CREATE TABLE lote_materia_prima (
    lmp_lote              VARCHAR(255) NOT NULL , 
    lmp_cantidad          INTEGER  NOT NULL , 
    lmp_fecha_recepcion   DATE  NOT NULL , 
    lmp_fecha_vencimiento DATE  NOT NULL , 
    fk_mp_lmp   INTEGER  NOT NULL,
    CONSTRAINT lote_materia_prima_PK PRIMARY KEY ( lmp_lote ),
    CONSTRAINT lote_materia_prima_materia_prima_FK FOREIGN KEY (fk_mp_lmp) 
    REFERENCES materia_prima (mp_id)
);

CREATE TABLE metodo_pago (
    mp_id                     INTEGER NOT NULL,
    mp_numero                 VARCHAR(255) NOT NULL,
    mp_tipo                   VARCHAR(50) NOT NULL, 
    mp_franquicia             VARCHAR(255),
    mp_fecha_vencimiento      DATE,
    mp_banco                  VARCHAR(255),
    fk_mp_swt_lg              INTEGER,
    mp_tjd_tipo_cuenta        VARCHAR(255),
    mp_cc_num_cheque          INTEGER,
    mp_ctatv_tipo             VARCHAR(255),
    mp_ctatv_direccion_wallet VARCHAR(255),
    fk_m_ctatv_mp             INTEGER,
    mp_pp_correo              VARCHAR(255),
    CONSTRAINT metodo_pago_PK PRIMARY KEY (mp_id),
    CONSTRAINT chk_mp_tipo CHECK (mp_tipo IN
    ('SWIFT',
     'TARJETA_CREDITO',
     'TARJETA_DEBITO', 
     'CHEQUE', 
     'CRIPTOACTIVO', 
     'PAYPAL')),
    CONSTRAINT swt_lugar_FK FOREIGN KEY (fk_mp_swt_lg) REFERENCES lugar (lg_id),
    CONSTRAINT criptoactivo_moneda_base_FK FOREIGN KEY (fk_m_ctatv_mp) REFERENCES moneda (m_id),
    CONSTRAINT tipo_cuenta_check CHECK(mp_tjd_tipo_cuenta IS NULL OR mp_tjd_tipo_cuenta IN('Ahorro', 'Corriente')),
    CONSTRAINT chk_req_tarjetas CHECK (
        (mp_tipo IN ('TARJETA_CREDITO', 'TARJETA_DEBITO') AND mp_franquicia IS NOT NULL AND mp_fecha_vencimiento IS NOT NULL) OR
        (mp_tipo NOT IN ('TARJETA_CREDITO', 'TARJETA_DEBITO') AND mp_franquicia IS NULL AND mp_fecha_vencimiento IS NULL)
    ),
    CONSTRAINT chk_req_td_especifico CHECK (
        (mp_tipo = 'TARJETA_DEBITO' AND mp_tjd_tipo_cuenta IS NOT NULL) OR
        (mp_tipo != 'TARJETA_DEBITO' AND mp_tjd_tipo_cuenta IS NULL)
    ),
    CONSTRAINT chk_req_bancos CHECK (
        (mp_tipo IN ('SWIFT', 'CHEQUE') AND mp_banco IS NOT NULL) OR
        (mp_tipo NOT IN ('SWIFT', 'CHEQUE') AND mp_banco IS NULL)
    ),
    CONSTRAINT chk_req_swift_especifico CHECK (
        (mp_tipo = 'SWIFT' AND fk_mp_swt_lg IS NOT NULL) OR
        (mp_tipo != 'SWIFT' AND fk_mp_swt_lg IS NULL)
    ),
    CONSTRAINT chk_req_cheque_especifico CHECK (
        (mp_tipo = 'CHEQUE' AND mp_cc_num_cheque IS NOT NULL) OR
        (mp_tipo != 'CHEQUE' AND mp_cc_num_cheque IS NULL)
    ),
    CONSTRAINT chk_req_cripto CHECK (
        (mp_tipo = 'CRIPTOACTIVO' AND mp_ctatv_tipo IS NOT NULL AND mp_ctatv_direccion_wallet IS NOT NULL AND fk_m_ctatv_mp IS NOT NULL) OR
        (mp_tipo != 'CRIPTOACTIVO' AND mp_ctatv_tipo IS NULL AND mp_ctatv_direccion_wallet IS NULL AND fk_m_ctatv_mp IS NULL)
    ),
    CONSTRAINT chk_req_paypal CHECK (
        (mp_tipo = 'PAYPAL' AND mp_pp_correo IS NOT NULL) OR
        (mp_tipo != 'PAYPAL' AND mp_pp_correo IS NULL)
    )
);
-- PREGUNTAR QUE DISEÑO QUIEREN, SI 1 PADRE O 1 CON TODO Y EL ATRIBUTO TIPO
CREATE TABLE metodo_pago (
    mp_id      INTEGER NOT NULL,
    mp_numero  INTEGER NOT NULL, 
    CONSTRAINT metodo_pago_PK PRIMARY KEY ( mp_id )
);

CREATE TABLE tarjeta_credito (
    mp_id                INTEGER NOT NULL,
    tjc_franquicia       VARCHAR(255) NOT NULL,
    tjc_fecha_vecimiento DATE NOT NULL, 
    CONSTRAINT tarjeta_credito_PK PRIMARY KEY ( mp_id ),
    CONSTRAINT tarjeta_credito_metodo_pago_FK FOREIGN KEY ( mp_id )
        REFERENCES metodo_pago ( mp_id )
);


CREATE TABLE tarjeta_debito (
    mp_id                 INTEGER NOT NULL,
    tjd_tipo_cuenta       VARCHAR(255) NOT NULL,
    tjd_franquicia        INTEGER NOT NULL,      
    tjc_fecha_vencimiento VARCHAR(255) NULL,     
    CONSTRAINT tarjeta_debito_PK PRIMARY KEY ( mp_id ),
    CONSTRAINT tarjeta_debito_metodo_pago_FK FOREIGN KEY ( mp_id )
        REFERENCES metodo_pago ( mp_id ),
    CONSTRAINT tjd_tipo_cuenta_check CHECK ( tjd_tipo_cuenta IN ('Ahorro', 'Corriente') )
);


CREATE TABLE paypal (
    mp_id     INTEGER NOT NULL,
    pp_correo VARCHAR(255) NOT NULL,
    CONSTRAINT paypal_PK PRIMARY KEY ( mp_id ),
    CONSTRAINT paypal_metodo_pago_FK FOREIGN KEY ( mp_id )
        REFERENCES metodo_pago ( mp_id )
);


CREATE TABLE swift (
    mp_id            INTEGER NOT NULL,
    swt_banco_nombre VARCHAR(255) NOT NULL,
    swt_pais         INTEGER NOT NULL, 
    CONSTRAINT swift_PK PRIMARY KEY ( mp_id ),
    CONSTRAINT swift_metodo_pago_FK FOREIGN KEY ( mp_id )
        REFERENCES metodo_pago ( mp_id )
);

CREATE TABLE cheque_corporativo (
    mp_id           INTEGER NOT NULL,
    cc_num_cheque   INTEGER NOT NULL,
    cc_banco_emisor VARCHAR(255) NOT NULL,
    CONSTRAINT cheque_corporativo_PK PRIMARY KEY ( mp_id ),
    CONSTRAINT cheque_corporativo_metodo_pago_FK FOREIGN KEY ( mp_id )
        REFERENCES metodo_pago ( mp_id )
);

CREATE TABLE criptoactivo (
    mp_id                  INTEGER NOT NULL,
    ctatv_tipo             VARCHAR(255) NOT NULL,
    ctatv_moneda_base      VARCHAR(255) NOT NULL,
    ctatv_direccion_wallet VARCHAR(255) NOT NULL,
    CONSTRAINT criptoactivo_PK PRIMARY KEY ( mp_id ),
    CONSTRAINT criptoactivo_metodo_pago_FK FOREIGN KEY ( mp_id )
        REFERENCES metodo_pago ( mp_id )
);

CREATE TABLE persona_juridica (
    pj_id               INTEGER  NOT NULL , 
    pj_nombre_comercial VARCHAR(255) NOT NULL , 
    pj_rif              VARCHAR(20)  NOT NULL , 
    pj_razon_social     VARCHAR(255) NOT NULL , 
    pj_direccion        VARCHAR(255) NOT NULL , 
    pj_correo           VARCHAR(255) NOT NULL , 
    pj_limite_credito   NUMERIC  NOT NULL , 
    pj_saldo_pendiente  NUMERIC  NOT NULL , 
    fk_lg_pj            INTEGER  NOT NULL,
    CONSTRAINT persona_juridica_PK PRIMARY KEY ( pj_id ),
    CONSTRAINT persona_juridica_lugar_FK FOREIGN KEY (fk_lg_pj) 
    REFERENCES lugar (lg_id)
);

CREATE TABLE usuario (
    usar_id             INTEGER  NOT NULL , 
    usar_nombre_usuario VARCHAR(255) NOT NULL , 
    usar_contrasena     VARCHAR(255) NOT NULL , 
    usar_correo         VARCHAR(255) NOT NULL , 
    usar_fecha_registro TIMESTAMP  NOT NULL , 
    fk_r_usar           INTEGER  NOT NULL , 
    fk_pn_usar          INTEGER , 
    fk_pj_usar INTEGER,
    CONSTRAINT juridica_natural_FK CHECK
	( 
        ((fk_pj_usar IS NOT NULL) AND (fk_pn_usar IS NULL)) OR 
        ((fk_pn_usar IS NOT NULL) AND (fk_pj_usar IS NULL))  
	),
    CONSTRAINT usuario_PK PRIMARY KEY ( usar_id ),
    CONSTRAINT usuario_persona_juridica_FK FOREIGN KEY (fk_pj_usar) 
    REFERENCES persona_juridica (pj_id),
    CONSTRAINT usuario_persona_natural_FK FOREIGN KEY (fk_pn_usar) 
    REFERENCES persona_natural (pn_id),
    CONSTRAINT usuario_rol_FK FOREIGN KEY (fk_r_usar) 
    REFERENCES rol (r_id)
    CONSTRAINT   usuario_empleado_FK FOREIGN KEY (fk_emp_usar) 
    REFERENCES empleado(epad_id)
);

CREATE TABLE categoria_producto (
    cp_id          INTEGER  NOT NULL , 
    cp_nombre      VARCHAR(255) NOT NULL , 
    cp_descripcion VARCHAR(255) NOT NULL , 
    fk_cp_cp       INTEGER,
    CONSTRAINT categoria_producto_PK PRIMARY KEY ( cp_id ),
    CONSTRAINT division_categoria_producto_FK FOREIGN KEY (fk_cp_cp) 
    REFERENCES categoria_producto (cp_id)
);

CREATE TABLE categoria_categoria (
    fk_cp_cp_1  INTEGER  NOT NULL , 
    fk_cp_cp_2  INTEGER  NOT NULL,
    CONSTRAINT categoria_categoria_PK PRIMARY KEY ( fk_cp_cp_1, fk_cp_cp_2),
    CONSTRAINT relacion_categoria_producto_FK FOREIGN KEY (fk_cp_cp_1) 
    REFERENCES categoria_producto (cp_id),
    CONSTRAINT vinculo_categoria_producto_FK FOREIGN KEY (fk_cp_cp_2) 
    REFERENCES categoria_producto (cp_id)
);

CREATE TABLE empleado (
    epad_id               INTEGER, 
    epad_primer_nombre    VARCHAR(255) NOT NULL , 
    epad_segundo_nombre   VARCHAR(255) , 
    epad_primer_apellido  VARCHAR(255) NOT NULL , 
    epad_segundo_apellido VARCHAR(255) , 
    epad_telefono         VARCHAR(255) NOT NULL , 
    epad_correo           VARCHAR(255) NOT NULL , 
    epad_direccion        VARCHAR(255) NOT NULL , 
    epad_cedula           VARCHAR(255) NOT NULL , 
    epad_fecha_nacimiento DATE  NOT NULL , 
    epad_rif              VARCHAR(255) NOT NULL , 
    fk_lg_epad            INTEGER  NOT NULL,
    CONSTRAINT empleado_PK PRIMARY KEY ( epad_id ),
    CONSTRAINT empleado_lugar_FK FOREIGN KEY (fk_lg_epad) 
    REFERENCES lugar (lg_id)
);

CREATE TABLE contrato (
    ctt_id             INTEGER  NOT NULL , 
    ctt_fecha_inicio   DATE  NOT NULL , 
    ctt_fecha_fin      DATE , 
    ctt_sueldo_base_us NUMERIC  NOT NULL , 
    fk_epad_ctt        INTEGER  NOT NULL , 
    fk_cg_ctt          INTEGER  NOT NULL,
    CONSTRAINT contrato_PK PRIMARY KEY 
    ( ctt_id, 
      fk_epad_ctt,
      fk_cg_ctt
    ),
    CONSTRAINT contrato_cargo_FK FOREIGN KEY (fk_cg_ctt) 
    REFERENCES cargo (cg_id),
    CONSTRAINT contrato_empleado_FK FOREIGN KEY (fk_epad_ctt) 
    REFERENCES empleado (epad_id)
);

CREATE TABLE compra_online (
    co_id             INTEGER  NOT NULL , 
    co_fecha_hora     TIMESTAMP  NOT NULL , 
    co_numero_compra  INTEGER  NOT NULL , 
    co_monto_total    NUMERIC  NOT NULL , 
    co_numero_factura INTEGER , 
    fk_pn_co         INTEGER  NOT NULL,
    CONSTRAINT compra_online_PK PRIMARY KEY ( co_id ),
    CONSTRAINT compra_online_persona_natural_FK FOREIGN KEY (fk_pn_co) 
    REFERENCES persona_natural (pn_id)
);

CREATE TABLE asistencia (
    astc_id                 INTEGER  NOT NULL , 
    astc_hora_entrada       TIMESTAMP  NOT NULL , 
    astc_hora_salida        TIMESTAMP  NOT NULL , 
    astc_fecha_laboral      TIMESTAMP  NOT NULL , 
    astc_horas_trabajadas   INTEGER  NOT NULL , 
    astc_horas_extra        INTEGER  NOT NULL , 
    fk_ctt_astc_1           INTEGER  NOT NULL , 
    fk_ctt_astc_2           INTEGER  NOT NULL , 
    fk_ctt_astc_3           INTEGER  NOT NULL,
    CONSTRAINT asistencia_PK PRIMARY KEY ( astc_id ),
    CONSTRAINT asistencia_contrato_FK FOREIGN KEY 
    (  
     fk_ctt_astc_1,
     fk_ctt_astc_2,
     fk_ctt_astc_3
    ) 
    REFERENCES contrato 
    ( 
     ctt_id,
     fk_epad_ctt, 
     fk_cg_ctt
    )
);

CREATE TABLE beneficio_contrato (
    bc_monto_acordado NUMERIC  NOT NULL , 
    fk_ctt_bc_1       INTEGER  NOT NULL , 
    fk_ctt_bc_2       INTEGER  NOT NULL , 
    fk_ctt_bc_3       INTEGER  NOT NULL , 
    fk_bnf_bc         INTEGER  NOT NULL,
    CONSTRAINT beneficio_contrato_PK PRIMARY KEY 
    ( fk_ctt_bc_1,
      fk_ctt_bc_2,
      fk_ctt_bc_3, 
      fk_bnf_bc
    ),
    CONSTRAINT beneficio_contrato_beneficio_FK FOREIGN KEY (fk_bnf_bc) 
    REFERENCES beneficio (bnf_id),
    CONSTRAINT beneficio_contrato_contrato_FK FOREIGN KEY 
    ( 
     fk_ctt_bc_1,
     fk_ctt_bc_2,
     fk_ctt_bc_3
    ) 
    REFERENCES contrato 
    ( 
     ctt_id,
     fk_epad_ctt,
     fk_cg_ctt
    )
);

CREATE TABLE contrato_horario (
    ch_dia    VARCHAR(255) NOT NULL , 
    ch_turno  VARCHAR(255) NOT NULL , 
    fk_hrr_ch INTEGER  NOT NULL , 
    fk_ctt_ch_1  INTEGER  NOT NULL , 
    fk_ctt_ch_2  INTEGER  NOT NULL , 
    fk_ctt_ch_3  INTEGER  NOT NULL,
    CONSTRAINT contrato_horario_PK PRIMARY KEY 
    ( fk_hrr_ch,
      fk_ctt_ch_1,
      fk_ctt_ch_2,
      fk_ctt_ch_3 
    ),
    CONSTRAINT contrato_horario_contrato_FK FOREIGN KEY 
    ( 
     fk_ctt_ch_1,
     fk_ctt_ch_2,
     fk_ctt_ch_3
    ) 
    REFERENCES contrato 
    ( 
     ctt_id,
     fk_epad_ctt,
     fk_cg_ctt
    ),
    CONSTRAINT contrato_horario_horario_FK FOREIGN KEY (fk_hrr_ch) 
    REFERENCES horario (hrr_id),
    CONSTRAINT dia_check CHECK(ch_dia IN
    ('Lunes',
     'Martes',
     'Miercoles',
     'Jueves',
     'Viernes',
     'Sabado',
     'Domingo'
    ))
);

CREATE TABLE diseno_producto (
    dp_id                    INTEGER  NOT NULL , 
    dp_nombre_comercial      VARCHAR(255) NOT NULL , 
    dp_ancho_cm              NUMERIC  NOT NULL , 
    dp_alto_cm               NUMERIC  NOT NULL , 
    dp_largo_cm              NUMERIC  NOT NULL , 
    dp_precio_minorista      NUMERIC  NOT NULL , 
    dp_precio_mayorista      NUMERIC  NOT NULL , 
    dp_acceso_prioritario    BOOLEAN  NOT NULL , 
    fk_eh_dp                 INTEGER  NOT NULL , 
    fk_ce_dp                 INTEGER  NOT NULL , 
    fk_cl_dp_ojos            INTEGER  NOT NULL , 
    fk_cl_dp_piel            INTEGER  NOT NULL , 
    dp_usa_bateria           BOOLEAN  NOT NULL , 
    fk_tc_dp                 INTEGER  NOT NULL , 
    fk_dp_dp                 INTEGER , 
    dp_limite_compra_usuario INTEGER  NOT NULL,
    CONSTRAINT diseno_producto_PK PRIMARY KEY ( dp_id ),
    CONSTRAINT diseno_producto_clasificacion_exclusividad_FK FOREIGN KEY (fk_ce_dp) 
    REFERENCES clasificacion_exclusividad (ce_id),
    CONSTRAINT diseno_producto_color_FK FOREIGN KEY (fk_cl_dp_ojos) 
    REFERENCES color (cl_id),
    CONSTRAINT diseno_producto_color_FKv2 FOREIGN KEY (fk_cl_dp_piel) 
    REFERENCES color (cl_id),
    CONSTRAINT diseno_producto_diseno_producto_FK FOREIGN KEY (fk_dp_dp) 
    REFERENCES diseno_producto (dp_id),
    CONSTRAINT diseno_producto_era_historica_FK FOREIGN KEY (fk_eh_dp) 
    REFERENCES era_historica (eh_id),
    CONSTRAINT diseno_producto_tipo_cuerpo_FK FOREIGN KEY (fk_tc_dp) 
    REFERENCES tipo_cuerpo (tc_id)
);

CREATE TABLE autor_diseno (
    ad_porcentaje_autoria   NUMERIC  NOT NULL , 
    fk_ctt_ad_1             INTEGER  NOT NULL , 
    fk_ctt_ad_2             INTEGER  NOT NULL , 
    fk_ctt_ad_3             INTEGER  NOT NULL , 
    fk_dp_ad                INTEGER  NOT NULL,
    CONSTRAINT autor_diseno_PK PRIMARY KEY
    ( fk_ctt_ad_1,
      fk_ctt_ad_2,
      fk_ctt_ad_3,
      fk_dp_ad
    ),
    CONSTRAINT autor_diseno_contrato_FK FOREIGN KEY 
    ( 
     fk_ctt_ad_1,
     fk_ctt_ad_2,
     fk_ctt_ad_3
    ) 
    REFERENCES contrato 
    ( 
     ctt_id,
     fk_epad_ctt, 
     fk_cg_ctt
    ),
    CONSTRAINT autor_diseno_diseno_producto_FK FOREIGN KEY (fk_dp_ad) 
    REFERENCES diseno_producto (dp_id)
);

CREATE TABLE dp_categoria (
    fk_dp_dpc INTEGER  NOT NULL , 
    fk_cp_dpc INTEGER  NOT NULL,
    CONSTRAINT dp_categoria_PK PRIMARY KEY ( fk_dp_dpc, fk_cp_dpc ),
    CONSTRAINT dp_categoria_categoria_producto_FK FOREIGN KEY (fk_cp_dpc) 
    REFERENCES categoria_producto (cp_id),
    CONSTRAINT dp_categoria_diseno_producto_FK FOREIGN KEY (fk_dp_dpc) 
    REFERENCES diseno_producto (dp_id)
);

CREATE TABLE dp_profesion (
    dpp_ano    DATE  NOT NULL , 
    fk_dp_dpp  INTEGER  NOT NULL , 
    fk_pfs_dpp INTEGER  NOT NULL,
    CONSTRAINT dp_pro_PK PRIMARY KEY ( fk_dp_dpp, fk_pfs_dpp ),
    CONSTRAINT dp_pro_diseno_producto_FK FOREIGN KEY (fk_dp_dpp) 
    REFERENCES diseno_producto (dp_id),
    CONSTRAINT dp_pro_profesion_FK FOREIGN KEY (fk_pfs_dpp) 
    REFERENCES profesion (pfs_id)
);

CREATE TABLE historico_valor_mercado (
    hvm_id                  INTEGER  NOT NULL , 
    hvm_fecha_hora_tasacion TIMESTAMP  NOT NULL , 
    hvm_precio_estimado     NUMERIC  NOT NULL , 
    hvm_fuente              VARCHAR(255) NOT NULL , 
    fk_dp_hvm               INTEGER  NOT NULL,
    CONSTRAINT historico_valor_mercado_PK PRIMARY KEY ( hvm_id ),
    CONSTRAINT historico_valor_mercado_diseno_producto_FK FOREIGN KEY (fk_dp_hvm) 
    REFERENCES diseno_producto (dp_id)
);

CREATE TABLE fase_prueba_diseno (
    fpd_id             INTEGER  NOT NULL , 
    fpd_numero_paso    INTEGER  NOT NULL , 
    fpd_dias_estimados INTEGER  NOT NULL , 
    fpd_tipo           VARCHAR(255) NOT NULL,
    fk_dp_fpd          INTEGER  NOT NULL , 
    fk_octlg_fpd       INTEGER  NOT NULL ,
    CONSTRAINT fase_prueba_diseno_PK PRIMARY KEY ( fpd_id ),
    CONSTRAINT fase_prueba_diseno_diseno_producto_FK FOREIGN KEY (fk_dp_fpd) 
    REFERENCES diseno_producto (dp_id),
    CONSTRAINT fase_prueba_diseno_operacion_catalogo_FK FOREIGN KEY (fk_octlg_fpd) 
    REFERENCES operacion_catalogo (octlg_id),
    CONSTRAINT tipo_fase_prueba_diseno CHECK(fpd_tipo IN('Producción','Prueba'))
);

CREATE TABLE taxonomia (
    txnm_cantidad_pieza    INTEGER  NOT NULL , 
    txnm_cantidad_material NUMERIC  NOT NULL , 
    fk_dp_txnm             INTEGER  NOT NULL , 
    fk_pz_txnm             INTEGER  NOT NULL , 
    fk_md_txnm             INTEGER  NOT NULL , 
    fk_mp_txnm             INTEGER  NOT NULL , 
    fk_cl_txnm             INTEGER,
    CONSTRAINT Taxonomia_PK PRIMARY KEY 
    ( fk_dp_txnm,
      fk_pz_txnm,
      fk_md_txnm
    ),
    CONSTRAINT Taxonomia_color_FK FOREIGN KEY (fk_cl_txnm) 
    REFERENCES color (cl_id),
    CONSTRAINT Taxonomia_diseno_producto_FK FOREIGN KEY (fk_dp_txnm) 
    REFERENCES diseno_producto (dp_id),
    CONSTRAINT Taxonomia_materia_prima_FK FOREIGN KEY (fk_mp_txnm) 
    REFERENCES materia_prima (mp_id),
    CONSTRAINT Taxonomia_molde_FK FOREIGN KEY (fk_md_txnm) 
    REFERENCES molde (md_id),
    CONSTRAINT Taxonomia_pieza_FK FOREIGN KEY (fk_pz_txnm) 
    REFERENCES pieza (pz_id)
);

CREATE TABLE prenomina (
    pnmn_id                   INTEGER  NOT NULL , 
    pnmn_fecha_inicio_periodo DATE  NOT NULL , 
    pnmn_fecha_fin_periodo    DATE  NOT NULL , 
    pnmn_estatus              VARCHAR(255) NOT NULL , 
    pnmn_monto                NUMERIC  NOT NULL , 
    fk_ctt_pnmn_1             INTEGER  NOT NULL , 
    fk_ctt_pnmn_2             INTEGER  NOT NULL , 
    fk_ctt_pnmn_3             INTEGER  NOT NULL , 
    fk_htc_pnmn_1             INTEGER  NOT NULL , 
    fk_htc_pnmn_2             INTEGER NOT NULL , 
    fk_htc_pnmn_3             INTEGER NOT NULL,
    CONSTRAINT prenomina_PK PRIMARY KEY ( pnmn_id ),
    CONSTRAINT prenomina_contrato_FK FOREIGN KEY 
    ( 
     fk_ctt_pnmn_1,
     fk_ctt_pnmn_2,
     fk_ctt_pnmn_3
    ) 
    REFERENCES contrato 
    ( 
     ctt_id,
     fk_epad_ctt, 
     fk_cg_ctt
    ),
    CONSTRAINT prenomina_historico_tasa_cambio_FK FOREIGN KEY 
    ( 
     fk_htc_pnmn_1,
     fk_htc_pnmn_2,
     fk_htc_pnmn_3
    ) 
    REFERENCES historico_tasa_cambio 
    ( 
     htc_id,
     fk_m_htc_1,
     fk_m_htc_2
    )
);

CREATE TABLE orden_compra (
    oc_id                INTEGER  NOT NULL , 
    oc_nombre_cadena     VARCHAR(255) NOT NULL , 
    oc_periodo_pago      INTEGER  NOT NULL , 
    oc_fecha_emision     DATE  NOT NULL , 
    oc_fecha_vencimiento DATE  NOT NULL , 
    oc_credito_utilizado NUMERIC NOT NULL ,  
    oc_estado            VARCHAR(255) NOT NULL , 
    oc_numero_factura    INTEGER ,  
    oc_monto_total       NUMERIC  NOT NULL , 
    oc_monto_abonado     NUMERIC  NOT NULL , 
    fk_pj_oc             INTEGER  NOT NULL ,
    fk_ctt_oc_1          INTEGER  NOT NULL , 
    fk_ctt_oc_2          INTEGER  NOT NULL , 
    fk_ctt_oc_3          INTEGER  NOT NULL,
    fk_oc_oc             INTEGER ,
    CONSTRAINT orden_compra_PK PRIMARY KEY ( oc_id ),
    CONSTRAINT orden_compra_contrato_FK FOREIGN KEY 
    ( 
     fk_ctt_oc_1,
     fk_ctt_oc_2,
     fk_ctt_oc_3
    ) 
    REFERENCES contrato 
    ( 
     ctt_id,
     fk_epad_ctt,
     fk_cg_ctt
    ),
    CONSTRAINT orden_compra_orden_compra_FK FOREIGN KEY (fk_oc_oc) 
    REFERENCES orden_compra (oc_id),
    CONSTRAINT orden_compra_persona_juridica_FK FOREIGN KEY (fk_pj_oc) 
    REFERENCES persona_juridica (pj_id),
    CONSTRAINT oc_estado_check CHECK(oc_estado IN
    ('Emitida', 
     'Validada', 
     'En Preparación', 
     'Despachada',
     'Entregada', 
     'Facturada', 
     'Cobrada', 
     'Cancelada', 
     'Devuelta'
    ))
);

CREATE TABLE subasta (
    sbt_id                INTEGER  NOT NULL , 
    sbt_precio_base       INTEGER  NOT NULL , 
    sbt_incremento_minimo INTEGER  NOT NULL , 
    sbt_precio_final      INTEGER , 
    sbt_fecha_hora_inicio TIMESTAMP  NOT NULL , 
    sbt_fecha_hora_fin    TIMESTAMP  NOT NULL,
    fk_cet_sbt            INTEGER  NOT NULL , 
    CONSTRAINT subasta_PK PRIMARY KEY ( sbt_id ),
    CONSTRAINT subasta_persona_natural_FK FOREIGN KEY (fk_cet_sbt) 
    REFERENCES persona_natural (cet_id)
);

CREATE TABLE puja (
    pj_monto       INTEGER  NOT NULL , 
    pj_fecha_hora  TIMESTAMP  NOT NULL , 
    fk_sbt_pj      INTEGER  NOT NULL , 
    fk_cet_pj      INTEGER  NOT NULL , 
    CONSTRAINT puja_PK PRIMARY KEY ( fk_sbt_pj, fk_cet_pj ),
    CONSTRAINT puja_persona_natural_FK FOREIGN KEY (fk_cet_pj) 
    REFERENCES persona_natural (cet_id),
    CONSTRAINT puja_subasta_FK FOREIGN KEY (fk_sbt_pj) 
    REFERENCES subasta (sbt_id)
);

CREATE TABLE orden_venta (
    ov_id             INTEGER  NOT NULL, 
    ov_fecha_hora     TIMESTAMP  NOT NULL, 
    ov_monto          INTEGER  NOT NULL, 
    ov_numero_factura INTEGER, 
    fk_sbt_ov         INTEGER  NOT NULL, 
    CONSTRAINT orden_venta_PK PRIMARY KEY ( ov_id ),
    CONSTRAINT orden_venta_subasta_FK FOREIGN KEY (fk_sbt_ov) 
    REFERENCES subasta (sbt_id),

); 



CREATE TABLE detalle_prenomina (
    dpnmn_id              INTEGER  NOT NULL , 
    dpnmn_monto_calculado NUMERIC  NOT NULL , 
    dpnmn_cantidad        INTEGER  NOT NULL , 
    fk_astc_dpnmn         INTEGER , 
    fk_bnf_dpnmn          INTEGER , 
    fk_pnmn_dpnmn         INTEGER  NOT NULL , 
    fk_bc_dpnmn_1         INTEGER  NOT NULL , 
    fk_bc_dpnmn_2         INTEGER  NOT NULL , 
    fk_bc_dpnmn_3         INTEGER  NOT NULL , 
    fk_bc_dpnmn_4         INTEGER  NOT NULL , 
    CONSTRAINT detalle_prenomina_PK PRIMARY KEY ( dpnmn_id ),
    CONSTRAINT detalle_prenomina_asistencia_FK FOREIGN KEY (fk_astc_dpnmn) 
    REFERENCES asistencia (astc_id),
    CONSTRAINT detalle_prenomina_beneficio_contrato_FK FOREIGN KEY 
    ( 
     fk_bc_dpnmn_1,
     fk_bc_dpnmn_2,
     fk_bc_dpnmn_3,
     fk_bc_dpnmn_4
    ) 
    REFERENCES beneficio_contrato 
    ( 
     fk_ctt_bc_1,
     fk_ctt_bc_2,
     fk_ctt_bc_3,
     fk_bnf_bc
    ),
    CONSTRAINT detalle_prenomina_beneficio_FK FOREIGN KEY (fk_bnf_dpnmn) 
    REFERENCES beneficio (bnf_id),
    CONSTRAINT detalle_prenomina_prenomina_FK FOREIGN KEY (fk_pnmn_dpnmn) 
    REFERENCES prenomina (pnmn_id)
);

CREATE TABLE fc_cargo (
    fc_cantidad INTEGER  NOT NULL, 
    fk_fpd_fc   INTEGER  NOT NULL, 
    fk_cg_fc               INTEGER  NOT NULL,
    CONSTRAINT fc_cargo_PK PRIMARY KEY ( fk_cg_fc, fk_fpd_fc ),
    CONSTRAINT fc_cargo_cargo_FK FOREIGN KEY (fk_cg_fc) 
    REFERENCES cargo (cg_id),
    CONSTRAINT fc_cargo_fase_prueba_diseno_FK FOREIGN KEY (fk_fpd_fc) 
    REFERENCES fase_prueba_diseno (fpd_id)
);


CREATE TABLE orden_produccion (
    op_id                       INTEGER NOT NULL, 
    op_cantidad_solicitada      INTEGER  NOT NULL, 
    op_fecha_creacion_orden     TIMESTAMP  NOT NULL, 
    op_fecha_finalizacion_orden TIMESTAMP, 
    fk_dp_op                    INTEGER  NOT NULL, 
    fk_txnma_op_1               INTEGER  NOT NULL, 
    fk_txnma_op_2               INTEGER  NOT NULL, 
    fk_txnma_op_3               INTEGER  NOT NULL, 
    fk_dpp_op_1                 INTEGER  NOT NULL, 
    fk_dpp_op_2                 INTEGER  NOT NULL,
    CONSTRAINT orden_produccion_PK PRIMARY KEY ( op_id ),
    CONSTRAINT orden_produccion_diseno_producto_FK FOREIGN KEY (fk_dp_op) 
    REFERENCES diseno_producto (dp_id),
    CONSTRAINT orden_produccion_dp_pro_FK FOREIGN KEY (fk_dpp_op_1, fk_dpp_op_2) 
    REFERENCES dp_profesion (fk_dp_dpp,fk_pfs_dpp),
    CONSTRAINT orden_produccion_Taxonomia_FK FOREIGN KEY 
    ( 
     fk_txnma_op_1,
     fk_txnma_op_2,
     fk_txnma_op_3
    ) 
    REFERENCES Taxonomia 
    ( 
     fk_dp_txnm,
     fk_pz_txnm,
     fk_md_txnm
    )
);

CREATE TABLE unidad_producto (
    up_sku                   INTEGER  NOT NULL , 
    up_precio_minorista      NUMERIC  NOT NULL , 
    up_precio_mayorista      NUMERIC  NOT NULL , 
    up_fecha_hora_disponible TIMESTAMP  NOT NULL , 
    fk_op_up                 INTEGER NOT NULL , 
    fk_fbc_up                INTEGER , 
    fk_sbt_up                INTEGER , 
    CONSTRAINT unidad_producto_PK PRIMARY KEY ( up_sku ),
    CONSTRAINT unidad_producto_fabrica_FK FOREIGN KEY (fk_fbc_up) 
    REFERENCES fabrica (fbc_id),
    CONSTRAINT unidad_producto_orden_produccion_FK FOREIGN KEY (fk_op_up) 
    REFERENCES orden_produccion (op_id),
    CONSTRAINT unidad_producto_subasta_FK FOREIGN KEY (fk_sbt_up) 
    REFERENCES subasta (sbt_id),
 
);

CREATE TABLE conciliacion_pago (
    cp_monto_aplicado INTEGER  NOT NULL , 
    cp_fecha_hora     TIMESTAMP  NOT NULL , 
    fk_oc_cp          INTEGER , 
    fk_co_cp          INTEGER , 
    fk_ov_cp          INTEGER ,
    CONSTRAINT tipo_compra_check CHECK ( 
        (  (fk_oc_cp IS NOT NULL) AND 
         (fk_co_cp IS NULL)  AND 
         (fk_ov_cp IS NULL) ) OR 
        (  (fk_co_cp IS NOT NULL) AND 
         (fk_oc_cp IS NULL)  AND 
         (fk_ov_cp IS NULL) ) OR 
        (  (fk_ov_cp IS NOT NULL) AND 
         (fk_oc_cp IS NULL)  AND 
         (fk_co_cp IS NULL) )  ),
    CONSTRAINT conciliacion_pago_compra_online_FK FOREIGN KEY (fk_co_cp) 
    REFERENCES compra_online (co_id),
    CONSTRAINT conciliacion_pago_orden_compra_FK FOREIGN KEY (fk_oc_cp) 
    REFERENCES orden_compra (oc_id),
    CONSTRAINT conciliacion_pago_orden_venta_FK FOREIGN KEY (fk_ov_cp) 
    REFERENCES orden_venta (ov_id),
    --FK de metodo pago
);

CREATE TABLE despacho (
    dpc_id               INTEGER  NOT NULL , 
    dpc_manifiesto_carga VARCHAR(500) , 
    dpc_numero_tracking  INTEGER , 
    dpc_direccion_envio  VARCHAR(255) NOT NULL , 
    dpc_costo            NUMERIC  NOT NULL , 
    fk_tpt_dpc           INTEGER  NOT NULL , 
    fk_ov_dpc            INTEGER , 
    fk_lg_dpc            INTEGER  NOT NULL , 
    fk_co_dpc            INTEGER,
    CONSTRAINT tipo_despacho CHECK ( 
        (  (fk_doc_dpc_1 IS NOT NULL) AND 
         (fk_doc_dpc_2 IS NOT NULL) AND 
         (fk_co_dpc IS NULL)  AND 
         (fk_ov_dpc IS NULL) ) OR 
        (  (fk_co_dpc IS NOT NULL) AND 
         (fk_doc_dpc_1 IS NULL)  AND 
         (fk_doc_dpc_2 IS NULL)  AND 
         (fk_ov_dpc IS NULL) ) OR 
        (  (fk_ov_dpc IS NOT NULL) AND 
         (fk_doc_dpc_1 IS NULL)  AND 
         (fk_doc_dpc_2 IS NULL)  AND 
         (fk_co_dpc IS NULL) )  ),
    CONSTRAINT despacho_PK PRIMARY KEY ( dpc_id),
    CONSTRAINT despacho_compra_online_FK FOREIGN KEY (fk_co_dpc) 
    REFERENCES compra_online ( co_id),
    CONSTRAINT despacho_lugar_FK FOREIGN KEY (fk_lg_dpc) 
    REFERENCES lugar (lg_id),
    CONSTRAINT despacho_orden_venta_FK FOREIGN KEY ( fk_ov_dpc) 
    REFERENCES orden_venta (ov_id),
    CONSTRAINT despacho_transporte_FK FOREIGN KEY (fk_tpt_dpc) 
    REFERENCES transporte (tpt_id)
);

CREATE TABLE fase_prueba_produccion (
    fpp_id           INTEGER  NOT NULL , 
    fpp_fecha_inicio DATE  NOT NULL , 
    fpp_fecha_fin    DATE  NOT NULL , 
    fpp_resultado    VARCHAR(255) NOT NULL , 
    fk_up_fpp        INTEGER NOT NULL , 
    fk_fpd_fpp       INTEGER  NOT NULL,
    CONSTRAINT fase_prueba_produccion_PK PRIMARY KEY ( fpp_id ),
    CONSTRAINT fase_prueba_produccion_fase_prueba_diseno_FK FOREIGN KEY (fk_fpd_fpp) 
    REFERENCES fase_prueba_diseno (fpd_id),
    CONSTRAINT fase_prueba_producion_unidad_producto_FK FOREIGN KEY (fk_up_fpp)
    REFERENCES unidad_producto (up_sku)
);

CREATE TABLE fpp_contrato (
    fppc_fecha_hora_inicio_labor TIMESTAMP  NOT NULL, 
    fppc_fecha_hora_fin_labor    TIMESTAMP  NOT NULL, 
    fk_ctt_fppc_1                INTEGER  NOT NULL, 
    fk_ctt_fppc_2                INTEGER  NOT NULL, 
    fk_ctt_fppc_3                INTEGER  NOT NULL, 
    fk_fpp_fppc                  INTEGER  NOT NULL,
    CONSTRAINT fpp_contrato_PK PRIMARY KEY ( fk_ctt_fppc_1, fk_ctt_fppc_2, fk_ctt_fppc_3, fk_fpp_fppc ),
    CONSTRAINT fpp_contrato_contrato_FK FOREIGN KEY 
    ( 
     fk_ctt_fppc_1,
     fk_ctt_fppc_2,
     fk_ctt_fppc_3
    ) 
    REFERENCES contrato 
    ( 
     ctt_id,
     fk_epad_ctt,
     fk_cg_ctt
    ),
    CONSTRAINT fpp_contrato_fase_prueba_produccion_FK FOREIGN KEY (fk_fpp_fppc) 
    REFERENCES fase_prueba_produccion(fpp_id)
);

CREATE TABLE consumo_materia_prima (
    cmp_cantidad_usada NUMERIC  NOT NULL , 
    fk_lmp_cmp         VARCHAR(255) NOT NULL , 
    fk_up_cmp          INTEGER  NOT NULL,
    CONSTRAINT consumo_materia_prima_PK PRIMARY KEY (fk_up_cmp,fk_lmp_cmp),
    CONSTRAINT consumo_materia_prima_lote_materia_prima_FK FOREIGN KEY (fk_lmp_cmp) 
    REFERENCES lote_materia_prima (lmp_lote),
    CONSTRAINT consumo_materia_prima_unidad_producto_FK FOREIGN KEY (fk_up_cmp) 
    REFERENCES unidad_producto (up_sku)
);

CREATE TABLE historial_post_venta (
    hpv_id                  INTEGER  NOT NULL , 
    hpv_tipo_evento         VARCHAR(255) NOT NULL , 
    hpv_fecha_hora_evento   TIMESTAMP  NOT NULL , 
    hpv_estado_conservacion VARCHAR(255) NOT NULL , 
    hpv_precio_transaccion  NUMERIC , 
    hpv_observaciones       VARCHAR(255), 
    fk_up_hpv               INTEGER  NOT NULL , 
    fk_cet_hpv              INTEGER,
    CONSTRAINT historial_post_venta_PK PRIMARY KEY ( hpv_id ),
    CONSTRAINT historial_post_venta_persona_natural_FK FOREIGN KEY (fk_cet_hpv) 
    REFERENCES persona_natural (cet_id),
    CONSTRAINT historial_post_venta_unidad_producto_FK FOREIGN KEY (fk_up_hpv) 
    REFERENCES unidad_producto (up_sku),
    CONSTRAINT hpv_conservacion_check CHECK(hpv_estado_conservacion IN
    ('NRFB',
    'Mint',
    'Restoration Needed'
    ))
);
CREATE TABLE estatus (
    ett_id          INTEGER NOT NULL,
    ett_nombre      VARCHAR(255) NOT NULL,
    ett_descripcion VARCHAR(255) NOT NULL,
    CONSTRAINT estatus_PK PRIMARY KEY ( ett_id )
);

CREATE UNIQUE INDEX persona_natural__IDX ON persona_natural (fk_crt_cet ASC);
CREATE UNIQUE INDEX conciliacion_pago__IDX ON conciliacion_pago (fk_co_cp ASC);
CREATE UNIQUE INDEX conciliacion_pago__IDXv1 ON conciliacion_pago (fk_ov_cp ASC);
CREATE UNIQUE INDEX orden_venta__IDX ON orden_venta (fk_sbt_ov ASC);
CREATE UNIQUE INDEX usuario__IDX ON usuario (fk_pn_usar ASC);
CREATE UNIQUE INDEX usuario__IDXv1 ON usuario (fk_pj_usar ASC);