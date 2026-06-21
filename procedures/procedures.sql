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
-- -----------------------------------------------------------------------------
-- reporte_inventario_por_cabello_piel: cantidad de SKUs disponibles para la venta
-- agrupados por color de cabello y tono de piel.
--   * color de cabello -> color de la pieza 'Cabello Enraizado' en taxonomía.
--   * tono de piel      -> color del diseño (fk_cl_dp_piel).
--   * SKU disponible    -> unidad con estatus vigente 'Disponible'.
-- Uso desde JasperReports:  SELECT * FROM reporte_inventario_por_cabello_piel()
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION reporte_inventario_por_cabello_piel()
RETURNS TABLE (
    color_cabello    VARCHAR(255),
    tono_piel        VARCHAR(255),
    skus_disponibles BIGINT
) LANGUAGE sql AS $$
    SELECT
        c_cab.cl_nombre,
        c_piel.cl_nombre,
        count(*)
    FROM unidad_producto up
        JOIN orden_produccion op ON op.op_id = up.fk_op_up
        JOIN diseno_producto  dp ON dp.dp_id = op.fk_dp_op
        -- stock disponible para la venta
        JOIN historico_estatus he ON he.fk_up_he = up.up_sku
                                 AND he.he_fecha_hora_fin IS NULL
        JOIN estatus e            ON e.ett_id = he.fk_ett_he
                                 AND e.ett_nombre = 'Disponible'
        -- tono de piel (color del diseño)
        JOIN color c_piel ON c_piel.cl_id = dp.fk_cl_dp_piel
        -- color de cabello (color de la pieza 'Cabello Enraizado' en taxonomía)
        JOIN taxonomia tx ON tx.fk_dp_txnm = dp.dp_id
        JOIN pieza pz     ON pz.pz_id = tx.fk_pz_txnm
                         AND pz.pz_nombre = 'Cabello Enraizado'
        JOIN color c_cab  ON c_cab.cl_id = tx.fk_cl_txnm
    GROUP BY c_cab.cl_nombre, c_piel.cl_nombre
    ORDER BY count(*) DESC, c_cab.cl_nombre, c_piel.cl_nombre;
$$;

-- -----------------------------------------------------------------------------
-- reporte_accesorios_compatibles: accesorios/mobiliarios compatibles con un modelo
-- específico de dreamhouse, indicando si existe stock de cada uno.
--   * compatibilidad -> el accesorio apunta al dreamhouse vía diseno_producto.fk_dp_dp.
--   * "con stock"     -> tiene al menos una unidad con estatus vigente 'Disponible'.
-- Uso desde JasperReports:  SELECT * FROM reporte_accesorios_compatibles($P{DREAMHOUSE_ID})
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION reporte_accesorios_compatibles(p_dreamhouse_id INTEGER)
RETURNS TABLE (
    accesorio_id      INTEGER,
    accesorio         VARCHAR(255),
    unidades_en_stock BIGINT,
    hay_stock         BOOLEAN
) LANGUAGE sql AS $$
    SELECT
        acc.dp_id,
        acc.dp_nombre_comercial,
        count(up.up_sku) FILTER (WHERE e.ett_nombre = 'Disponible'),
        count(up.up_sku) FILTER (WHERE e.ett_nombre = 'Disponible') > 0
    FROM diseno_producto acc
        LEFT JOIN orden_produccion op ON op.fk_dp_op = acc.dp_id
        LEFT JOIN unidad_producto  up ON up.fk_op_up = op.op_id
        LEFT JOIN historico_estatus he ON he.fk_up_he = up.up_sku
                                      AND he.he_fecha_hora_fin IS NULL
        LEFT JOIN estatus e            ON e.ett_id = he.fk_ett_he
    WHERE acc.fk_dp_dp = p_dreamhouse_id
    GROUP BY acc.dp_id, acc.dp_nombre_comercial
    ORDER BY (count(up.up_sku) FILTER (WHERE e.ett_nombre = 'Disponible') > 0) DESC,
             acc.dp_nombre_comercial;
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

-- -----------------------------------------------------------------------------
-- login_usuario: autentica un usuario por correo y contraseña.
-- Retorna los datos de sesión si las credenciales son correctas.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION login_usuario(
    p_correo     VARCHAR,
    p_contrasena VARCHAR
)
RETURNS TABLE (
    usar_id             INTEGER,
    usar_nombre_usuario VARCHAR,
    usar_correo         VARCHAR,
    r_id                INTEGER,
    r_nombre            VARCHAR,
    r_descripcion       VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.usar_id,
        u.usar_nombre_usuario,
        u.usar_correo,
        r.r_id,
        r.r_nombre,
        r.r_descripcion
    FROM usuario u
    INNER JOIN rol r ON r.r_id = u.fk_r_usar
    WHERE u.usar_correo    = p_correo
      AND u.usar_contrasena = p_contrasena;
END;
$$;

GRANT EXECUTE ON FUNCTION login_usuario(VARCHAR, VARCHAR) TO anon;
GRANT EXECUTE ON FUNCTION login_usuario(VARCHAR, VARCHAR) TO authenticated;

-- -----------------------------------------------------------------------------
-- listar_usuarios: todos los usuarios del sistema con su nombre real y tipo.
-- Resuelve la unión polimórfica: empleado | persona_natural | persona_juridica.
-- El administrador ve los tres tipos en una sola tabla.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION listar_usuarios()
RETURNS TABLE (
    usar_id             INTEGER,
    usar_nombre_usuario VARCHAR,
    usar_correo         VARCHAR,
    usar_fecha_registro TIMESTAMP,
    r_id                INTEGER,
    r_nombre            VARCHAR,
    r_descripcion       VARCHAR,
    nombre_completo     VARCHAR,
    tipo_vinculo        VARCHAR
)
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    RETURN QUERY
    SELECT
        u.usar_id,
        u.usar_nombre_usuario,
        u.usar_correo,
        u.usar_fecha_registro,
        r.r_id,
        r.r_nombre,
        r.r_descripcion,
        CASE
            WHEN u.fk_emp_usar IS NOT NULL
                THEN (e.epad_primer_nombre  || ' ' || e.epad_primer_apellido)::VARCHAR
            WHEN u.fk_pn_usar IS NOT NULL
                THEN (pn.pn_primer_nombre   || ' ' || pn.pn_primer_apellido)::VARCHAR
            WHEN u.fk_pj_usar IS NOT NULL
                THEN pj.pj_razon_social::VARCHAR
            ELSE '—'::VARCHAR
        END AS nombre_completo,
        CASE
            WHEN u.fk_emp_usar IS NOT NULL THEN 'Empleado'::VARCHAR
            WHEN u.fk_pn_usar  IS NOT NULL THEN 'Cliente B2C'::VARCHAR
            WHEN u.fk_pj_usar  IS NOT NULL THEN 'Empresa B2B'::VARCHAR
            ELSE '—'::VARCHAR
        END AS tipo_vinculo
    FROM usuario u
    INNER JOIN rol              r  ON r.r_id    = u.fk_r_usar
    LEFT  JOIN empleado         e  ON e.epad_id = u.fk_emp_usar
    LEFT  JOIN persona_natural  pn ON pn.pn_id  = u.fk_pn_usar
    LEFT  JOIN persona_juridica pj ON pj.pj_id  = u.fk_pj_usar
    ORDER BY u.usar_id ASC;
END;
$$;

GRANT EXECUTE ON FUNCTION listar_usuarios() TO anon;
GRANT EXECUTE ON FUNCTION listar_usuarios() TO authenticated;
 
-- -----------------------------------------------------------------------------
-- listar_roles: todos los roles disponibles.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION listar_roles()
RETURNS TABLE (r_id INTEGER, r_nombre VARCHAR, r_descripcion VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    RETURN QUERY
    SELECT r.r_id, r.r_nombre, r.r_descripcion FROM rol r ORDER BY r.r_id ASC;
END;
$$;
 
GRANT EXECUTE ON FUNCTION listar_roles() TO anon;
GRANT EXECUTE ON FUNCTION listar_roles() TO authenticated;
 
-- -----------------------------------------------------------------------------
-- crear_usuario: crea un usuario vinculándolo a la entidad correcta según p_tipo.
--
--   'empleado'  -> INSERT en empleado         + fk_emp_usar   (usuarios internos)
--   'cliente'   -> INSERT en persona_natural  + fk_pn_usar    (consumidores B2C)
--   'empresa'   -> INSERT en persona_juridica + fk_pj_usar    (Retail Partners B2B)
--
-- Los campos exclusivos de empresa (p_nombre_comercial, p_rif, p_limite_credito)
-- son opcionales para los otros tipos y se ignoran si no corresponden.
-- Esto respeta el CHECK juridica_natural_empleado_FK de la tabla usuario.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE crear_usuario(
    p_nombre_usuario   VARCHAR,
    p_correo           VARCHAR,
    p_contrasena       VARCHAR,
    p_rol              INTEGER,
    p_tipo             VARCHAR,   -- 'empleado' | 'cliente' | 'empresa'
    -- Campos comunes (persona natural / empleado)
    p_primer_nombre    VARCHAR,
    p_primer_apellido  VARCHAR,
    p_cedula           VARCHAR,
    p_telefono         VARCHAR,
    p_direccion        VARCHAR,
    -- Campos exclusivos de empresa (B2B)
    p_razon_social     VARCHAR  DEFAULT NULL,
    p_nombre_comercial VARCHAR  DEFAULT NULL,
    p_rif              VARCHAR  DEFAULT NULL,
    p_limite_credito   NUMERIC  DEFAULT 0
)
LANGUAGE plpgsql AS $$
DECLARE
    v_emp_id INTEGER;
    v_pn_id  INTEGER;
    v_pj_id  INTEGER;
BEGIN
    -- ── Validaciones generales ────────────────────────────────────────────────
    IF p_nombre_usuario IS NULL OR btrim(p_nombre_usuario) = '' THEN
        RAISE EXCEPTION 'El nombre de usuario no puede estar vacío.';
    END IF;
    IF p_correo IS NULL OR btrim(p_correo) = '' THEN
        RAISE EXCEPTION 'El correo no puede estar vacío.';
    END IF;
    IF p_contrasena IS NULL OR btrim(p_contrasena) = '' THEN
        RAISE EXCEPTION 'La contraseña no puede estar vacía.';
    END IF;
    IF p_tipo IS NULL OR btrim(p_tipo) NOT IN ('empleado', 'cliente', 'empresa') THEN
        RAISE EXCEPTION 'El tipo debe ser "empleado", "cliente" o "empresa". Recibido: %', p_tipo;
    END IF;
 
    -- Validaciones extra para empresa
    IF btrim(p_tipo) = 'empresa' THEN
        IF p_razon_social IS NULL OR btrim(p_razon_social) = '' THEN
            RAISE EXCEPTION 'La razón social es obligatoria para empresas B2B.';
        END IF;
        IF p_rif IS NULL OR btrim(p_rif) = '' THEN
            RAISE EXCEPTION 'El RIF es obligatorio para empresas B2B.';
        END IF;
        IF p_limite_credito IS NULL OR p_limite_credito < 0 THEN
            RAISE EXCEPTION 'El límite de crédito debe ser mayor o igual a cero.';
        END IF;
    END IF;
 
    -- ── Unicidad de credenciales ──────────────────────────────────────────────
    IF NOT EXISTS (SELECT 1 FROM rol WHERE r_id = p_rol) THEN
        RAISE EXCEPTION 'El rol con ID % no existe.', p_rol;
    END IF;
    IF EXISTS (SELECT 1 FROM usuario WHERE usar_nombre_usuario = btrim(p_nombre_usuario)) THEN
        RAISE EXCEPTION 'Ya existe un usuario con el nombre "%".', btrim(p_nombre_usuario);
    END IF;
    IF EXISTS (SELECT 1 FROM usuario WHERE usar_correo = btrim(p_correo)) THEN
        RAISE EXCEPTION 'Ya existe un usuario con el correo "%".', btrim(p_correo);
    END IF;
 
    -- ── Rama EMPLEADO ─────────────────────────────────────────────────────────
    IF btrim(p_tipo) = 'empleado' THEN
        INSERT INTO empleado (
            epad_primer_nombre, epad_primer_apellido, epad_cedula,
            epad_telefono, epad_correo, epad_direccion,
            epad_fecha_nacimiento, epad_rif, fk_lg_epad
        ) VALUES (
            btrim(p_primer_nombre), btrim(p_primer_apellido), btrim(p_cedula),
            btrim(p_telefono), btrim(p_correo), btrim(p_direccion),
            CURRENT_DATE, 'J-00000000-0', 1
        ) RETURNING epad_id INTO v_emp_id;
 
        INSERT INTO usuario (
            usar_nombre_usuario, usar_contrasena, usar_correo,
            usar_fecha_registro, fk_r_usar, fk_emp_usar
        ) VALUES (
            btrim(p_nombre_usuario), btrim(p_contrasena), btrim(p_correo),
            NOW(), p_rol, v_emp_id
        );
        RAISE NOTICE 'Empleado + usuario "%" creados con rol ID %.', btrim(p_nombre_usuario), p_rol;
 
    -- ── Rama CLIENTE B2C ──────────────────────────────────────────────────────
    ELSIF btrim(p_tipo) = 'cliente' THEN
        INSERT INTO persona_natural (
            pn_primer_nombre, pn_primer_apellido, pn_cedula,
            pn_telefono, pn_correo, pn_direccion,
            pn_fecha_nacimiento, pn_rif, pn_tipo, fk_lg_pn
        ) VALUES (
            btrim(p_primer_nombre), btrim(p_primer_apellido), btrim(p_cedula),
            btrim(p_telefono), btrim(p_correo), btrim(p_direccion),
            CURRENT_DATE, 'J-00000000-0', 'Normal', 1
        ) RETURNING pn_id INTO v_pn_id;
 
        INSERT INTO usuario (
            usar_nombre_usuario, usar_contrasena, usar_correo,
            usar_fecha_registro, fk_r_usar, fk_pn_usar
        ) VALUES (
            btrim(p_nombre_usuario), btrim(p_contrasena), btrim(p_correo),
            NOW(), p_rol, v_pn_id
        );
        RAISE NOTICE 'Cliente B2C + usuario "%" creados con rol ID %.', btrim(p_nombre_usuario), p_rol;
 
    -- ── Rama EMPRESA B2B ──────────────────────────────────────────────────────
    ELSE
        INSERT INTO persona_juridica (
            pj_razon_social, pj_nombre_comercial, pj_rif,
            pj_correo, pj_direccion,
            pj_limite_credito, pj_saldo_pendiente, fk_lg_pj
        ) VALUES (
            btrim(p_razon_social), btrim(COALESCE(p_nombre_comercial, p_razon_social)),
            btrim(p_rif),
            btrim(p_correo), btrim(p_direccion),
            p_limite_credito, 0, 1
        ) RETURNING pj_id INTO v_pj_id;
 
        INSERT INTO usuario (
            usar_nombre_usuario, usar_contrasena, usar_correo,
            usar_fecha_registro, fk_r_usar, fk_pj_usar
        ) VALUES (
            btrim(p_nombre_usuario), btrim(p_contrasena), btrim(p_correo),
            NOW(), p_rol, v_pj_id
        );
        RAISE NOTICE 'Empresa B2B + usuario "%" creados con rol ID %.', btrim(p_nombre_usuario), p_rol;
    END IF;
END;
$$;
 
GRANT EXECUTE ON PROCEDURE crear_usuario(
    VARCHAR, VARCHAR, VARCHAR, INTEGER, VARCHAR,
    VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR, VARCHAR, NUMERIC
) TO authenticated;
 
-- -----------------------------------------------------------------------------
-- eliminar_usuario: elimina un usuario por ID.
--   - NO elimina la entidad vinculada para conservar el historial.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE eliminar_usuario(p_id_usuario INTEGER)
LANGUAGE plpgsql AS $$
DECLARE
    v_nombre VARCHAR;
BEGIN
    SELECT usar_nombre_usuario INTO v_nombre FROM usuario WHERE usar_id = p_id_usuario;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El usuario con ID % no existe.', p_id_usuario;
    END IF;
    DELETE FROM usuario WHERE usar_id = p_id_usuario;
    RAISE NOTICE 'Usuario "%" (ID %) eliminado exitosamente.', v_nombre, p_id_usuario;
END;
$$;
 
GRANT EXECUTE ON PROCEDURE eliminar_usuario(INTEGER) TO authenticated;

