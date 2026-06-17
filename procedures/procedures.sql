-- =============================================================================
-- PROCEDIMIENTOS ALMACENADOS - GESTIÓN DE ROLES Y PERMISOS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- modificar_rol_usuario: cambia el rol asignado a un usuario existente.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE modificar_rol_usuario(p_id_usuario INTEGER, p_id_rol INTEGER) LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM usuario
        WHERE usar_id = p_id_usuario
    ) THEN
        RAISE EXCEPTION 'El usuario con ID % no existe.', p_id_usuario;
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM rol
        WHERE r_id = p_id_rol
    ) THEN
        RAISE EXCEPTION 'El rol con ID % no existe.', p_id_rol;
    END IF;
    UPDATE usuario
    SET fk_r_usar = p_id_rol
    WHERE usar_id = p_id_usuario;

    RAISE NOTICE 'Rol modificado exitosamente para el usuario %', p_id_usuario;
END;
$$;

-- -----------------------------------------------------------------------------
-- crear_rol: agrega un nuevo rol al sistema.
--   - Valida que el nombre y la descripción no vengan vacíos.
--   - Evita nombres de rol duplicados (sin distinguir mayúsculas/minúsculas).
--   - El r_id lo genera la secuencia SERIAL automáticamente.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE crear_rol(p_nombre VARCHAR, p_descripcion VARCHAR) LANGUAGE plpgsql AS $$
BEGIN
    IF p_nombre IS NULL OR btrim(p_nombre) = '' THEN
        RAISE EXCEPTION 'El nombre del rol no puede estar vacío.';
    END IF;

    IF p_descripcion IS NULL OR btrim(p_descripcion) = '' THEN
        RAISE EXCEPTION 'La descripción del rol no puede estar vacía.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM rol
        WHERE lower(r_nombre) = lower(btrim(p_nombre))
    ) THEN
        RAISE EXCEPTION 'Ya existe un rol con el nombre "%".', btrim(p_nombre);
    END IF;

    INSERT INTO rol (r_nombre, r_descripcion)
    VALUES (btrim(p_nombre), btrim(p_descripcion));

    RAISE NOTICE 'Rol "%" creado exitosamente.', btrim(p_nombre);
END;
$$;

-- -----------------------------------------------------------------------------
-- eliminar_rol: elimina un rol SOLO si ningún usuario lo tiene asignado.
--   - Falla si el rol no existe.
--   - Falla (y no borra nada) si algún usuario está usando el rol.
--   - Antes de borrar el rol, limpia sus asociaciones en rol_permiso para no
--     violar la llave foránea rol_permiso -> rol.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE eliminar_rol(p_id_rol INTEGER) LANGUAGE plpgsql AS $$
DECLARE
    v_nombre_rol         VARCHAR(255);
    v_usuarios_asignados INTEGER;
    v_permisos_removidos INTEGER;
BEGIN
    -- 1. El rol debe existir (de paso obtenemos su nombre para los mensajes).
    SELECT r_nombre INTO v_nombre_rol
    FROM rol
    WHERE r_id = p_id_rol;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El rol con ID % no existe.', p_id_rol;
    END IF;

    -- 2. No debe estar asignado a ningún usuario.
    SELECT COUNT(*) INTO v_usuarios_asignados
    FROM usuario
    WHERE fk_r_usar = p_id_rol;

    IF v_usuarios_asignados > 0 THEN
        RAISE EXCEPTION 'No se puede eliminar el rol "%" (ID %): está asignado a % usuario(s).',
            v_nombre_rol, p_id_rol, v_usuarios_asignados;
    END IF;

    -- 3. Limpiar permisos asociados al rol (evita violar la FK rol_permiso -> rol).
    DELETE FROM rol_permiso
    WHERE fk_r_rp = p_id_rol;
    GET DIAGNOSTICS v_permisos_removidos = ROW_COUNT;

    -- 4. Eliminar el rol.
    DELETE FROM rol
    WHERE r_id = p_id_rol;

    RAISE NOTICE 'Rol "%" (ID %) eliminado. Se removieron % asociación(es) de permisos.',
        v_nombre_rol, p_id_rol, v_permisos_removidos;
END;
$$;

-- -----------------------------------------------------------------------------
-- agregar_permiso_rol: asigna un permiso (privilegio) a un rol.
--   - Valida que tanto el rol como el permiso existan.
--   - Evita duplicar una asignación que ya exista.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE agregar_permiso_rol(p_id_rol INTEGER, p_id_permiso INTEGER) LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM rol
        WHERE r_id = p_id_rol
    ) THEN
        RAISE EXCEPTION 'El rol con ID % no existe.', p_id_rol;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM permiso
        WHERE pms_id = p_id_permiso
    ) THEN
        RAISE EXCEPTION 'El permiso con ID % no existe.', p_id_permiso;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM rol_permiso
        WHERE fk_r_rp = p_id_rol
          AND fk_pms_rp = p_id_permiso
    ) THEN
        RAISE EXCEPTION 'El rol % ya tiene asignado el permiso %.', p_id_rol, p_id_permiso;
    END IF;

    INSERT INTO rol_permiso (fk_r_rp, fk_pms_rp)
    VALUES (p_id_rol, p_id_permiso);

    RAISE NOTICE 'Permiso % asignado al rol % exitosamente.', p_id_permiso, p_id_rol;
END;
$$;

-- -----------------------------------------------------------------------------
-- eliminar_permiso_rol: quita un permiso (privilegio) de un rol.
--   - Valida que tanto el rol como el permiso existan.
--   - Falla si la asignación rol-permiso no existía (no hay nada que quitar).
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE eliminar_permiso_rol(p_id_rol INTEGER, p_id_permiso INTEGER) LANGUAGE plpgsql AS $$
DECLARE
    v_filas_afectadas INTEGER;
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM rol
        WHERE r_id = p_id_rol
    ) THEN
        RAISE EXCEPTION 'El rol con ID % no existe.', p_id_rol;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM permiso
        WHERE pms_id = p_id_permiso
    ) THEN
        RAISE EXCEPTION 'El permiso con ID % no existe.', p_id_permiso;
    END IF;

    DELETE FROM rol_permiso
    WHERE fk_r_rp = p_id_rol
      AND fk_pms_rp = p_id_permiso;
    GET DIAGNOSTICS v_filas_afectadas = ROW_COUNT;

    IF v_filas_afectadas = 0 THEN
        RAISE EXCEPTION 'El rol % no tiene asignado el permiso %; no hay nada que eliminar.',
            p_id_rol, p_id_permiso;
    END IF;

    RAISE NOTICE 'Permiso % removido del rol % exitosamente.', p_id_permiso, p_id_rol;
END;
$$;

-- -----------------------------------------------------------------------------
-- reporte_skus_retirados: SKUs con stock físico cuyo diseño fue retirado en el
-- PLM hace más de p_meses meses (por defecto 6).
--   * "stock físico"    -> unidad cuyo estatus vigente es 'Disponible'.
--   * "diseño retirado" -> diseño con estatus vigente 'Retirada' (tipo 'Diseño').
-- Uso desde JasperReports:  SELECT * FROM reporte_skus_retirados($P{MESES_UMBRAL})
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION reporte_skus_retirados(p_meses INTEGER DEFAULT 6)
RETURNS TABLE (
    sku                VARCHAR(50),
    diseno_id          INTEGER,
    diseno             VARCHAR(255),
    fecha_retiro       TIMESTAMP,
    meses_desde_retiro INTEGER,
    precio_minorista   NUMERIC,
    disponible_desde   TIMESTAMP
) LANGUAGE sql AS $$
    SELECT
        up.up_sku,
        dp.dp_id,
        dp.dp_nombre_comercial,
        he_ret.he_fecha_hora_inicio,
        ( EXTRACT(YEAR  FROM age(CURRENT_DATE, he_ret.he_fecha_hora_inicio)) * 12
        + EXTRACT(MONTH FROM age(CURRENT_DATE, he_ret.he_fecha_hora_inicio)) )::int,
        up.up_precio_minorista,
        up.up_fecha_hora_disponible
    FROM unidad_producto up
        JOIN orden_produccion op ON op.op_id = up.fk_op_up
        JOIN diseno_producto  dp ON dp.dp_id = op.fk_dp_op
        -- (1) El SKU está EN STOCK: su estatus vigente es 'Disponible'
        JOIN historico_estatus he_u ON he_u.fk_up_he = up.up_sku
                                   AND he_u.he_fecha_hora_fin IS NULL
        JOIN estatus e_u            ON e_u.ett_id = he_u.fk_ett_he
                                   AND e_u.ett_nombre = 'Disponible'
        -- (2) El DISEÑO está RETIRADO: estatus vigente 'Retirada' de tipo 'Diseño'
        JOIN historico_estatus he_ret ON he_ret.fk_dp_he = dp.dp_id
                                     AND he_ret.he_fecha_hora_fin IS NULL
        JOIN estatus e_ret            ON e_ret.ett_id = he_ret.fk_ett_he
                                     AND e_ret.ett_nombre = 'Retirada'
                                     AND e_ret.ett_tipo   = 'Diseño'
    -- (3) El retiro ocurrió hace MÁS de p_meses meses
    WHERE he_ret.he_fecha_hora_inicio < (CURRENT_DATE - make_interval(months => p_meses))
    ORDER BY dp.dp_nombre_comercial, up.up_sku;
$$;

-- =============================================================================
-- PROCEDIMIENTOS ALMACENADOS - GESTIÓN DE DISEÑOS DE PRODUCTO
-- =============================================================================

- -----------------------------------------------------------------------------
-- ver_lista_diseno_producto muestra la información de un diseño de producto existente.
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION lista_diseno_producto()
RETURNS TABLE (
    dp_id INTEGER,
    dp_nombre_comercial VARCHAR,
    dp_ancho_cm NUMERIC,
    dp_largo_cm NUMERIC,
    dp_alto_cm NUMERIC,
    dp_precio_minorista NUMERIC,
    dp_precio_mayorista NUMERIC,
    dp_acceso_prioritario TEXT,
    dp_usa_bateria TEXT,
    dp_limite_compra_usuario INTEGER,
    eh_nombre VARCHAR,
    ce_nombre VARCHAR,
    cl_ojos VARCHAR,
    cl_piel VARCHAR,
    tc_nombre VARCHAR,
    ett_nombre VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        dp.dp_id,
        dp.dp_nombre_comercial,
        dp.dp_ancho_cm,
        dp.dp_largo_cm,
        dp.dp_alto_cm,
        dp.dp_precio_minorista,
        dp.dp_precio_mayorista,
        CASE WHEN dp.dp_acceso_prioritario THEN 'Sí' ELSE 'No' END,
        CASE WHEN dp.dp_usa_bateria THEN 'Sí' ELSE 'No' END,
        dp.dp_limite_compra_usuario,
        eh.eh_nombre,
        ce.ce_nombre,
        c1.cl_nombre AS cl_ojos, 
        c2.cl_nombre AS cl_piel, 
        tc.tc_nombre,
        e.ett_nombre
    FROM diseno_producto dp
        JOIN era_historica eh ON eh.eh_id = dp.fk_eh_dp
        JOIN clasificacion_exclusividad ce ON ce.ce_id = dp.fk_ce_dp
        JOIN color c1 ON c1.cl_id = dp.fk_cl_dp_ojos
        JOIN color c2 ON c2.cl_id = dp.fk_cl_dp_piel
        JOIN tipo_cuerpo tc ON tc.tc_id = dp.fk_tc_dp
        JOIN historico_estatus he ON he.fk_dp_he = dp.dp_id AND he.he_fecha_hora_fin IS NULL
        JOIN estatus e ON e.ett_id = he.fk_ett_he;
END;
$$;