library(data.table)
library(tidyverse)

data_payments <- fread("/Users/ruggerodoino/Library/CloudStorage/Dropbox/ChilePaymentProcurement/Reproducible-Package/Data/Intermediate/Payments/dt_tot_payments.csv")
data_pos <- fread("/Users/ruggerodoino/Library/CloudStorage/Dropbox/COVID_19/CHILE/Reproducible-Package/Data/Final/purchase_orders.csv")

data_payments_2 = data_payments[, .(mean = mean(amt_pay_ack_dd, na.rm = TRUE)), by = .(id_purchase_order)]
data_pos_2 = data_pos[,.(
  COVID_LABEL = mean(COVID_LABEL, na.rm = TRUE), 
  CAT_PROBLEMATIC = mean(CAT_PROBLEMATIC, na.rm = TRUE), 
  CAT_MEDICAL = mean(CAT_MEDICAL, na.rm = TRUE),
  DT_MONTH = first(DT_MONTH),
  DT_YEAR = first(DT_YEAR),
  DT_S = first(DT_S)
),
by = .(ID_PURCHASE_ORDER, ID_ITEM_UNSPSC)][]

data_pos_2 = data_pos_2[COVID_LABEL %in% c(0, 1, NaN) | CAT_PROBLEMATIC %in% c(0, 1, NaN) | CAT_MEDICAL %in% c(0, 1, NaN),]
setnames(data_payments_2, "id_purchase_order", "ID_PURCHASE_ORDER")
data = merge.data.table(data_pos_2, data_payments_2, by = "ID_PURCHASE_ORDER")

graph_trend <- function(
    data, 
    variable, 
    treatment, 
    title, 
    caption,
    limit_lower,
    limit_upper, 
    interval_limits_y,
    legend_upper,
    label_treatment_legend = "Covid-19 items",
    label_control_legend = "Other items",
    label_control_2_legend = "Other Medical Products",
    percentage = FALSE,
    yearly = FALSE
) {
  
  variable <- enquo(variable)
  treatment <- enquo(treatment)
  
  if (yearly == FALSE) {
    
    plot <- ggplot() +
      
      ggplot2::annotate("segment", x = 8.5, xend = 8.5, y = limit_lower - limit_lower*0.1, yend = limit_upper, color = "black", alpha = 0.5, size = 1, linetype = 2) +
      geom_point(data = data %>% filter(!!treatment == 1), aes(x = DT_S, y = !!variable), shape = 16, size = 3, color = "#FF0100") +
      geom_point(data = data %>% filter(!!treatment == 0), aes(x = DT_S, y = !!variable), shape = 18, size = 4, color = "#18466E") +
      geom_line(data = data %>% filter(!!treatment == 1), aes(x = DT_S, y = !!variable), size = 0.7, color = "#FF0100") +
      geom_line(data = data %>% filter(!!treatment == 0), aes(x = DT_S, y = !!variable), size = 0.7, color = "#18466E", linetype = 2)  +
      labs(title    = title,
           caption  = caption,
           x = NULL,
           y = NULL) +
      scale_x_continuous(breaks = seq(1,14),
                         labels = c(
                           "<b>2016 S1</b>",
                           "<b>2016 S2</b>",
                           "<b>2017 S1</b>",
                           "<b>2017 S2</b>",
                           "<b>2018 S1</b>",
                           "<b>2018 S2</b>",
                           "<b>2019 S1</b>",
                           "<b>2019 S2</b>",
                           "<b>2020 S1</b>",
                           "<b>2020 S2</b>",
                           "<b>2021 S1</b>",
                           "<b>2021 S2</b>",
                           "<b>2022 S1</b>",
                           "<b>2022 S2</b>"
                         ),
                         limits = c(0, 17),
                         expand = c(0, 0)) +
      scale_y_continuous(
        breaks = seq(limit_lower, limit_upper, by = interval_limits_y)
      ) +
      coord_cartesian(
        expand = FALSE,
        clip   = "off"
      ) + 
      theme(
        aspect.ratio = 3.2/7,
        text = element_text(family = "Roboto"),
        plot.margin = margin(0, 5, 0, 5),
        panel.background = element_rect(fill = "white"),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(color = "darkgrey"),
        axis.ticks.length = unit(.25, "cm"),
        legend.text = element_blank(),
        legend.title = element_blank(),
        legend.key.width = unit(25,"pt"),
        legend.key.height = unit(15, "pt"),
        axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
        axis.text.y = element_blank(),
        axis.line.x  = element_line(color = "gray8"),
        axis.ticks.y = element_blank(),
        plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
        plot.caption = element_text(hjust = 0, size = 9),
        plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5),
        legend.position="none") + 
      ggplot2::annotate("segment", color = "#FF0100", x = 13, xend = 14, y = legend_upper + legend_upper * 0.03, yend = legend_upper + legend_upper * 0.03, size = 1) +
      ggplot2::annotate("segment", linetype = 2, color = "#18466E", x = 13, xend = 14, y = legend_upper - legend_upper * 0.1, yend = legend_upper - legend_upper * 0.1, size = 1) +
      geom_point(aes(x = 13.55, y = legend_upper + legend_upper * 0.03), shape = 16, size = 3, color = "#FF0100") +
      geom_point(aes(x = 13.55, y = legend_upper - legend_upper * 0.1), shape = 18, size = 4, color = "#18466E") +
      geom_text( family = "Roboto", fontface = "bold", x = 15.2, y = legend_upper + legend_upper * 0.03, aes(label = label_treatment_legend)) +
      geom_text( family = "Roboto", fontface = "bold", x = 15, y = legend_upper - legend_upper * 0.1, aes(label = label_control_legend)) 
    
    if (percentage == TRUE) {
      
      plot <- plot +
        geom_text(
          data = data.frame(x = 17, y = seq(limit_lower, limit_upper, by = interval_limits_y)),
          aes(x, y, label = paste0(y, "%")),
          hjust = 1, # Align to the right
          vjust = - 0.5, # Align to the bottom
          size = 5
        )
      
    } else {
      
      plot <- plot +
        geom_text(
          data = data.frame(x = 17, y = seq(limit_lower, limit_upper, by = interval_limits_y)),
          aes(x, y, label = y),
          hjust = 1, # Align to the right
          vjust = - 0.5, # Align to the bottom
          size = 5
        )
      
    }
    
    return(plot)
    
  }}

data_plot_s = data[,
                 .(mean = mean(mean, na.rm = TRUE)), by = .(
                   DT_S,
                   COVID_LABEL
                 )]


plot <- graph_trend(
  data = data_plot_s, 
  treatment = COVID_LABEL,
  variable = mean, 
  title = "Average Number of Days between Recepcion Conforme and Fecha Pago",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 80,
  interval_limits_y = 5,
  legend_upper = 75,
  yearly = FALSE,
  label_treatment_legend = "Covid items",
  label_control_legend = "Others"
)
ggsave(
  filename = "plot_covid_pay.png",
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

data_plot_s = data[,
                   .(mean = mean(mean, na.rm = TRUE)), by = .(
                     DT_S,
                     CAT_PROBLEMATIC
                   )]
plot <- graph_trend(
  data = data_plot_s, 
  treatment = CAT_PROBLEMATIC,
  variable = mean, 
  title = "Average Number of Days between Recepcion Conforme and Fecha Pago",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 120,
  interval_limits_y = 5,
  legend_upper = 115,
  yearly = FALSE,
  label_treatment_legend = "Masks and respirators",
  label_control_legend = "Gloves and vests"
)
ggsave(
  filename = "plot_problematic_pay.png",
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

data_plot_s = data[,
                   .(mean = mean(mean, na.rm = TRUE)), by = .(
                     DT_S,
                     CAT_MEDICAL
                   )]
plot <- graph_trend(
  data = data_plot_s, 
  treatment = CAT_MEDICAL,
  variable = mean, 
  title = "Average Number of Days between Recepcion Conforme and Fecha Pago",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 120,
  interval_limits_y = 5,
  legend_upper = 115,
  yearly = FALSE,
  label_treatment_legend = "Health Items",
  label_control_legend = "Others"
)
ggsave(
  filename = "plot_medical_pay.png",
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

data = data[, SECTOR := substr(ID_ITEM_UNSPSC, 0, 2)] %>% 
  .[CAT_MEDICAL == 1, SECTOR := 42] %>% 
  .[SECTOR == 0, SECTOR := NA] %>% 
  .[,
    SECTOR := fcase(
      SECTOR == 42, "Health Sector",
      SECTOR == 50, "Food Beverage and Tobacco Products",
      SECTOR == 44, "Office Equipment and Accessories and Supplies",
      SECTOR == 72, "Building and Facility Construction and Maintenance Services", default = "Other Sectors"
    )
  ] %>% 
  .[,
    MED_DUMMY := fcase(
      SECTOR == "Health Sector", 1,
      SECTOR == "Food Beverage and Tobacco Products", 0, 
      SECTOR == "Office Equipment and Accessories and Supplies", 2, 
      SECTOR == "Building and Facility Construction and Maintenance Services", 3, default = 4
    )
  ]

graph_trend <- function(
    data, 
    variable, 
    treatment, 
    title, 
    caption,
    limit_lower,
    limit_upper, 
    interval_limits_y,
    legend_upper,
    label_treatment_legend = "Health",
    label_control_legend = "Food Beverage and Tobacco",
    label_control_2_legend = "Office Equipment",
    label_control_3_legend = "Building and Maintenance Services",
    label_control_4_legend = "Other Sectors",
    percentage = FALSE,
    yearly = FALSE,
    adjust_value = 0.1
) {
  
  variable <- enquo(variable)
  treatment <- enquo(treatment)
  
  if (yearly == FALSE) {
    
    y_values = seq(from = limit_upper + 0.1, by = interval_limits_y*adjust_value, length.out = 5)
    
    plot <- ggplot() +
      
      ggplot2::annotate("segment", x = 8.5, xend = 8.5, y = limit_lower - limit_lower*0.1, yend = limit_upper, color = "black", alpha = 0.5, size = 1, linetype = 2) +
      
      geom_point(data = data %>% filter(!!treatment == 1), aes(x = DT_S, y = !!variable), shape = 16, size = 3, color = "#FF0100") +
      geom_line(data = data %>% filter(!!treatment == 1), aes(x = DT_S, y = !!variable), size = 0.7, color = "#FF0100") +
      geom_point(data = data %>% filter(!!treatment == 0), aes(x = DT_S, y = !!variable), shape = 17, size = 3, color = "#18466E") +
      geom_line(data = data %>% filter(!!treatment == 0), aes(x = DT_S, y = !!variable), size = 0.7, color = "#18466E", linetype = 2)  +
      geom_point(data = data %>% filter(!!treatment == 2), aes(x = DT_S, y = !!variable), shape = 18, size = 3, color = "#6BA841") +
      geom_line(data = data %>% filter(!!treatment == 2), aes(x = DT_S, y = !!variable), size = 0.7, color = "#6BA841", linetype = 3)  +
      geom_point(data = data %>% filter(!!treatment == 3), aes(x = DT_S, y = !!variable), shape = 19, size = 3, color = "#F79D31") +
      geom_line(data = data %>% filter(!!treatment == 3), aes(x = DT_S, y = !!variable), size = 0.7, color = "#F79D31", linetype = 4) +
      geom_point(data = data %>% filter(!!treatment == 4), aes(x = DT_S, y = !!variable), shape = 8, size = 3, color = "#873F76") +
      geom_line(data = data %>% filter(!!treatment == 4), aes(x = DT_S, y = !!variable), size = 0.7, color = "#873F76", linetype = 5) +
      
      scale_x_continuous(breaks = seq(1,14),
                         labels = c(
                           "<b>2016 S1</b>",
                           "<b>2016 S2</b>",
                           "<b>2017 S1</b>",
                           "<b>2017 S2</b>",
                           "<b>2018 S1</b>",
                           "<b>2018 S2</b>",
                           "<b>2019 S1</b>",
                           "<b>2019 S2</b>",
                           "<b>2020 S1</b>",
                           "<b>2020 S2</b>",
                           "<b>2021 S1</b>",
                           "<b>2021 S2</b>",
                           "<b>2022 S1</b>",
                           "<b>2022 S2</b>"
                         ),
                         limits = c(0, 17),
                         expand = c(0, 0)) +
      scale_y_continuous(
        breaks = seq(limit_lower, limit_upper, by = interval_limits_y)
      ) +
      coord_cartesian(
        expand = FALSE,
        clip   = "off"
      ) + 
      theme(
        aspect.ratio = 3.2/7,
        text = element_text(family = "Roboto"),
        plot.margin = margin(0, 5, 0, 5),
        panel.background = element_rect(fill = "white"),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(color = "darkgrey"),
        axis.ticks.length = unit(.25, "cm"),
        legend.text = element_blank(),
        legend.title = element_blank(),
        legend.key.width = unit(25,"pt"),
        legend.key.height = unit(15, "pt"),
        axis.text.x = ggtext::element_markdown(size = 12, color = "black", angle = 55, hjust = 1),
        axis.text.y = element_blank(),
        axis.line.x  = element_line(color = "gray8"),
        axis.ticks.y = element_blank(),
        plot.title = element_text(size = rel(1.5), hjust = 0, face = "bold", vjust = 5),
        plot.caption = element_text(hjust = 0, size = 9),
        plot.subtitle = element_text(size = rel(1), hjust = 0, vjust = 5),
        legend.position="none")  +
      
      labs(
        title = title,
        caption = caption,
        x = "",
        y = ""
      ) +
      
      guides(
        color = guide_legend(override.aes = list(shape = c(16, 17, 18, 19, 8), linetype = c(1, 2, 3, 4, 5))),
        shape = guide_legend(override.aes = list(color = c("#FF0100", "#18466E", "#6BA841", "#F79D31", "#873F76")))
      ) +
      
      scale_color_manual(
        values = c("#FF0100", "#18466E", "#6BA841", "#F79D31", "#873F76"),
        labels = c(label_treatment_legend, label_control_legend, label_control_2_legend, label_control_3_legend, label_control_4_legend),
        breaks = c("#FF0100", "#18466E", "#6BA841", "#F79D31", "#873F76")
      )  +
      
      geom_segment(aes(x = 13, xend = 14, y = y_values[1], yend = y_values[1]), colour = "#FF0100", linetype = 1, size = 0.7) +
      geom_point(aes(x = 13.5, y = y_values[1]), color = "#FF0100", shape = 16, size = 3) +
      geom_text(aes(x = 14.2, y = y_values[1]), label = label_treatment_legend, hjust = 0) +
      
      geom_segment(aes(x = 13, xend = 14, y = y_values[2], yend = y_values[2]), colour = "#18466E", linetype = 2, size = 0.7) +
      geom_point(aes(x = 13.5, y = y_values[2]), color = "#18466E", shape = 17, size = 3) +
      geom_text(aes(x = 14.2, y = y_values[2]), label = label_control_legend, hjust = 0) +
      
      geom_segment(aes(x = 13, xend = 14, y = y_values[3], yend = y_values[3]), colour = "#6BA841", linetype = 3, size = 0.7) +
      geom_point(aes(x = 13.5, y = y_values[3]), color = "#6BA841", shape = 18, size = 3) +
      geom_text(aes(x = 14.2, y = y_values[3]), label = label_control_2_legend, hjust = 0) +
      
      geom_segment(aes(x = 13, xend = 14, y = y_values[4], yend = y_values[4]), colour = "#F79D31", linetype = 4, size = 0.7) +
      geom_point(aes(x = 13.5, y = y_values[4]), color = "#F79D31", shape = 19, size = 3) +
      geom_text(aes(x = 14.2, y = y_values[4]), label = label_control_3_legend, hjust = 0) +
      
      geom_segment(aes(x = 13, xend = 14, y = y_values[5], yend = y_values[5]), colour = "#873F76", linetype = 5, size = 0.7) +
      geom_point(aes(x = 13.5, y = y_values[5]), color = "#873F76", shape = 8, size = 3) +
      geom_text(aes(x = 14.2, y = y_values[5]), label = label_control_4_legend, hjust = 0) 
    
    
    if (percentage == TRUE) {
      
      plot <- plot +
        geom_text(
          data = data.frame(x = 17, y = seq(limit_lower, limit_upper, by = interval_limits_y)),
          aes(x, y, label = paste0(y, "%")),
          hjust = 1, # Align to the right
          vjust = - 0.5, # Align to the bottom
          size = 5
        )
      
    } else {
      
      plot <- plot +
        geom_text(
          data = data.frame(x = 17, y = seq(limit_lower, limit_upper, by = interval_limits_y)),
          aes(x, y, label = y),
          hjust = 1, # Align to the right
          vjust = - 0.5, # Align to the bottom
          size = 5
        )
      
    }
    
    return(plot)
  }
}

data_plot_s = data[,
                   .(mean = mean(mean, na.rm = TRUE)), by = .(
                     DT_S,
                     SECTOR, MED_DUMMY
                   )]

plot <- graph_trend(
  data = data_plot_s, 
  treatment = MED_DUMMY,
  variable = mean, 
  title = "Average Number of Days between Recepcion Conforme and Fecha Pago",
  caption = "Source: Chile Compra",
  limit_lower = 0,
  limit_upper = 150,
  interval_limits_y = 10,
  legend_upper = 120,
  yearly = FALSE,
  adjust_value = 0.8
)
ggsave(
  filename = "plot_sector_pay.png",
  plot = plot                                                ,
  width    = 11                                            ,
  height   = 7                                             ,
  dpi      = 250                                              ,
  units    = "in"                                             ,
  device   = 'png'
)

