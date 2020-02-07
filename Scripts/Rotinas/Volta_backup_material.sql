DECLARE
	CURSOR WCUR IS
		SELECT	id,
				cod_astrein,
				cod_antigo,
				tp_mat,
				centro_san,
				dep,
				org_vendas,
				cn_distrib,
				desc_san,
				un_med_bas_san,
				grp_merc,
				grp_compr,
				un_med_ped_san,
				den_conv_um,
				um_alt_san,
				qtd_bas,
				txt_lon_mm_san,
				ped_aut,
				ncm_san,
				mat_ctg_cfop,
				pos_dep_san,
				cent_luc,
				clas_aval,
				prec_padr_san,
				un_prec,
				util_mat,
				orig_mat,
				prod_int,
				tipo_mrp,
				pt_reab_san,
				plan_mrp,
				tam_fx_lt_san,
				rg_calc_tam_lt,
				pz_entr_prev,
				umid,
				set_atv,
				clas_fis_mat,
				grp_clas_cont_mat,
				grp_ctg_it_m_mat,
				grp_trans,
				grp_carreg,
				txt_lon_sd,
				grp_frete_mat,
				status,
				info,
				observacao,
				ctg_aval,
				status_1,
				status_2,
				status_3,
				status_4,
				status_5,
				class_mat,
				cq,
				pb,
				pl,
				ta,
				blq,
				dta_ult_movi
		FROM	MATERIAL_BKP;
	REC WCUR %ROWTYPE;
	
BEGIN
	OPEN WCUR;
	LOOP
		FETCH WCUR INTO REC;
		EXIT WHEN WCUR%NOTFOUND;
		
		BEGIN
			UPDATE	STAGING_MATERIAL 
			SET	id                  =	REC.id,
				cod_astrein         =   REC.cod_astrein,
				cod_antigo          =   REC.cod_antigo,
				tp_mat              =   REC.tp_mat,
				centro_san          =   REC.centro_san,
				dep                 =   REC.dep,
				org_vendas          =   REC.org_vendas,
				cn_distrib          =   REC.cn_distrib,
				desc_san            =   REC.desc_san,
				un_med_bas_san      =   REC.un_med_bas_san,
				grp_merc            =   REC.grp_merc,
				grp_compr           =   REC.grp_compr,
				un_med_ped_san      =   REC.un_med_ped_san,
				den_conv_um         =   REC.den_conv_um,
				um_alt_san          =   REC.um_alt_san,
				qtd_bas             =   REC.qtd_bas,
				txt_lon_mm_san      =   REC.txt_lon_mm_san,
				ped_aut             =   REC.ped_aut,
				ncm_san             =   REC.ncm_san,
				mat_ctg_cfop        =   REC.mat_ctg_cfop,
				pos_dep_san         =   REC.pos_dep_san,
				cent_luc            =   REC.cent_luc,
				clas_aval           =   REC.clas_aval,
				prec_padr_san       =   REC.prec_padr_san,
				un_prec             =   REC.un_prec,
				util_mat            =   REC.util_mat,
				orig_mat            =   REC.orig_mat,
				prod_int            =   REC.prod_int,
				tipo_mrp            =   REC.tipo_mrp,
				pt_reab_san         =   REC.pt_reab_san,
				plan_mrp            =   REC.plan_mrp,
				tam_fx_lt_san       =   REC.tam_fx_lt_san,
				rg_calc_tam_lt      =   REC.rg_calc_tam_lt,
				pz_entr_prev        =   REC.pz_entr_prev,
				umid                =   REC.umid,
				set_atv             =   REC.set_atv,
				clas_fis_mat		=   REC.clas_fis_mat,
				grp_clas_cont_mat	=   REC.grp_clas_cont_mat,
				grp_ctg_it_m_mat	=   REC.grp_ctg_it_m_mat,
				grp_trans           =   REC.grp_trans,
				grp_carreg          =   REC.grp_carreg,
				txt_lon_sd          =   REC.txt_lon_sd,
				grp_frete_mat       =   REC.grp_frete_mat,
				status              =   REC.status,
				info                =   REC.info,
				observacao          =   REC.observacao,
				ctg_aval            =   REC.ctg_aval,
				status_1            =   REC.status_1,
				status_2            =   REC.status_2,
				status_3            =   REC.status_3,
				status_4            =   REC.status_4,
				status_5            =   REC.status_5,
				class_mat           =   REC.class_mat,
				cq                  =   REC.cq,
				pb                  =   REC.pb,
				pl                  =   REC.pl,
				ta                  =   REC.ta,
				blq                 =   REC.blq,
				dta_ult_movi        =   REC.dta_ult_movi
			WHERE	ID = REC.id  
			AND		COD_ASTREIN = REC.cod_astrein
			AND		COD_ANTIGO = REC.cod_antigo;
			
			COMMIT;
			
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('ERRO NO CODIGO ANTIGO: '||REC.cod_antigo||'; Erro Oracle: ' || TO_CHAR(SQLCODE)||'-'|| SQLERRM);
				NULL;
		END;
	END LOOP;
	
	CLOSE WCUR;
	COMMIT;
	
END;