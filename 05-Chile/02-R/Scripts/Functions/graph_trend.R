graph_trend <- function(
    data, 
    variable, 
    treatment, 
    title, 
    subtitle, 
    caption,
    limit_lower,
    limit_upper, 
    interval_limits_y,
    legend_upper,
    label_treatment_legend = "Covid-19 items",
    label_control_legend = "Other items",
    percentage = FALSE,
    yearly = FALSE
    ) {
  
  variable <- enquo(variable)
  treatment <- enquo(treatment)
  
  if (yearly == FALSE) {
    
    plot <- ggplot() +
      
      ggplot2::annotate("segment", x = 7.5, xend = 7.5, y = limit_lower - limit_lower*0.1, yend = limit_upper, color = "black", alpha = 0.5, size = 1, linetype = 2) +
      geom_point(data = data %>% filter(!!treatment == 1), aes(x = DT_S, y = !!variable), shape = 16, size = 3, color = "#FF0100") +
      geom_point(data = data %>% filter(!!treatment == 0), aes(x = DT_S, y = !!variable), shape = 18, size = 4, color = "#18466E") +
      geom_line(data = data %>% filter(!!treatment == 1), aes(x = DT_S, y = !!variable), size = 0.7, color = "#FF0100") +
      geom_line(data = data %>% filter(!!treatment == 0), aes(x = DT_S, y = !!variable), size = 0.7, color = "#18466E", linetype = 2)  +
      labs(title    = title,
           subtitle = subtitle,
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
    
  } else {
    
    plot <- ggplot() +
      
      ggplot2::annotate("segment", x = 2018.5, xend = 2018.5, y = limit_lower - limit_lower*0.1, yend = limit_upper, color = "black", alpha = 0.5, size = 1, linetype = 2) +
      geom_point(data = data %>% filter(!!treatment == 1), aes(x = as.numeric(DT_Y), y = !!variable), shape = 16, size = 3, color = "#FF0100") +
      geom_point(data = data %>% filter(!!treatment == 0), aes(x = as.numeric(DT_Y), y = !!variable), shape = 18, size = 4, color = "#18466E") +
      geom_line(data = data %>% filter(!!treatment == 1), aes(x = as.numeric(DT_Y), y = !!variable), size = 0.7, color = "#FF0100") +
      geom_line(data = data %>% filter(!!treatment == 0), aes(x = as.numeric(DT_Y), y = !!variable), size = 0.7, color = "#18466E", linetype = 2) +
      labs(title    = title,
           subtitle = subtitle,
           caption  = caption,
           x = NULL,
           y = NULL) +
      scale_x_continuous(breaks = seq(2016,2022),
                         labels = c(
                           "<b>2016</b>",
                           "<b>2017</b>",
                           "<b>2018</b>",
                           "<b>2019</b>",
                           "<b>2020</b>",
                           "<b>2021</b>",
                           "<b>2022</b>"
                         ),
                         limits = c(2015.5, 2024),
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
      ggplot2::annotate("segment", color = "#FF0100", x = 2021.5, xend = 2022, y = legend_upper + legend_upper * 0.03, yend = legend_upper + legend_upper * 0.03, size = 1) +
      ggplot2::annotate("segment", linetype = 2, color = "#18466E", x = 2021.5, xend = 2022, y = legend_upper - legend_upper * 0.03, yend = legend_upper - legend_upper * 0.03, size = 1) +
      geom_point(aes(x = 2021.75, y = legend_upper + legend_upper * 0.03), shape = 16, size = 3, color = "#FF0100") +
      geom_point(aes(x = 2021.75, y = legend_upper - legend_upper * 0.03), shape = 18, size = 4, color = "#18466E") +
      geom_text( family = "Roboto", fontface = "bold", x = 2022.2, y = legend_upper + legend_upper * 0.03, aes(label = label_treatment_legend)) +
      geom_text( family = "Roboto", fontface = "bold", x = 2022.2, y = legend_upper - legend_upper * 0.03, aes(label = label_control_legend))
    
    
    if (percentage == TRUE) {
      
      plot <- plot +
        geom_text(
          data = data.frame(x = 2024, y = seq(limit_lower, limit_upper, by = interval_limits_y)),
          aes(x, y, label = paste0(y, "%")),
          hjust = 1, # Align to the right
          vjust = - 0.5, # Align to the bottom
          size = 5
        )
      
    } else {
      
      plot <- plot +
        geom_text(
          data = data.frame(x = 2024, y = seq(limit_lower, limit_upper, by = interval_limits_y)),
          aes(x, y, label = y),
          hjust = 1, # Align to the right
          vjust = - 0.5, # Align to the bottom
          size = 5
        )
      
    }
    
  }
  
  return(plot)
  
}

graph_trend_no_treat <- function(
    data, 
    variable, 
    title, 
    subtitle, 
    caption,
    limit_lower,
    limit_upper, 
    interval_limits_y,
    legend_upper,
    percentage = FALSE,
    yearly = TRUE
) {
  
  variable <- enquo(variable)
  
  if (yearly == TRUE) {
    
    plot <- ggplot() +
    ggplot2::annotate(geom = "segment", xmin = 2018.5, xmax = 2019, ymin = limit_lower - limit_lower*0.1, ymax = limit_upper, color = "black", alpha = 0.5, size = 1, linetype = 2) +
      geom_point(data = data, aes(x = as.numeric(DT_Y), y = !!variable), shape = 18, size = 4, color = "#18466E") +
      geom_line(data = data, aes(x = as.numeric(DT_Y), y = !!variable), size = 0.7, color = "#18466E", linetype = 2) +
      labs(title    = title,
           subtitle = subtitle,
           caption  = caption,
           x = NULL,
           y = NULL) +
      scale_x_continuous(breaks = seq(2016,2022),
                         labels = c(
                           "<b>2016</b>",
                           "<b>2017</b>",
                           "<b>2018</b>",
                           "<b>2019</b>",
                           "<b>2020</b>",
                           "<b>2021</b>",
                           "<b>2022</b>"
                         ),
                         limits = c(2015.5, 2024),
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
        legend.position="none") 
    
    if (percentage == TRUE) {
      
      plot <- plot +
        geom_text(
          data = data.frame(x = 2024, y = seq(limit_lower, limit_upper, by = interval_limits_y)),
          aes(x, y, label = paste0(y, "%")),
          hjust = 1, # Align to the right
          vjust = - 0.5, # Align to the bottom
          size = 5
        )
      
    } else {
      
      plot <- plot +
        geom_text(
          data = data.frame(x = 2024, y = seq(limit_lower, limit_upper, by = interval_limits_y)),
          aes(x, y, label = y),
          hjust = 1, # Align to the right
          vjust = - 0.5, # Align to the bottom
          size = 5
        )
    }
    
  } else {
    
    plot <- ggplot() +
      
      ggplot2::annotate("segment", x = 7.5, xend = 7.5, y = limit_lower - limit_lower*0.1, yend = limit_upper, color = "black", alpha = 0.5, size = 1, linetype = 2) +
      geom_point(data = data, aes(x = DT_S, y = !!variable), shape = 16, size = 3, color = "#FF0100") +
      geom_line(data = data, aes(x = DT_S, y = !!variable), size = 0.7, color = "#FF0100") +
      labs(title    = title,
           subtitle = subtitle,
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
        legend.position="none")
    
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
    
  }


return(plot)

}

graph_trend_three_covid <- function(
    data, 
    variable,
    title, 
    subtitle, 
    caption,
    limit_lower,
    limit_upper, 
    interval_limits_y,
    legend_upper,
    percentage = FALSE,
    yearly = FALSE
) {
  
  variable <- enquo(variable)
  
  if (yearly == FALSE) {
    
    plot <- ggplot() +
      
      ggplot2::annotate("segment", x = 7.5, xend = 7.5, y = limit_lower - limit_lower*0.1, yend = limit_upper, color = "black", alpha = 0.5, size = 1, linetype = 2) +
      geom_point(data = data %>% filter(tender_covid == "ONLY COVID" & DT_S != 9), aes(x = DT_S, y = !!variable), shape = 16, size = 3, color = "#FF0100") +
      geom_point(data = data %>% filter(tender_covid == "ONLY NON COVID" & DT_S != 9), aes(x = DT_S, y = !!variable), shape = 18, size = 4, color = "#18466E") +
      geom_point(data = data %>% filter(tender_covid == "MIXED" & DT_S != 9), aes(x = DT_S, y = !!variable), shape = 18, size = 4, color = "#63A15D") +
      geom_line(data = data %>% filter(tender_covid == "ONLY COVID"), aes(x = DT_S, y = !!variable), size = 0.7, color = "#FF0100") +
      geom_line(data = data %>% filter(tender_covid == "ONLY NON COVID"), aes(x = DT_S, y = !!variable), size = 0.7, color = "#18466E", linetype = 2)  +
      geom_line(data = data %>% filter(tender_covid == "MIXED"), aes(x = DT_S, y = !!variable), size = 0.7, color = "#63A15D", linetype = 2)  +
      labs(title    = title,
           subtitle = subtitle,
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
      ggplot2::annotate("segment", linetype = 2, color = "#18466E", x = 13, xend = 14, y = legend_upper - legend_upper * 0.03, yend = legend_upper - legend_upper * 0.03, size = 1) +
      ggplot2::annotate("segment", linetype = 2, color = "#63A15D", x = 13, xend = 14, y = legend_upper - legend_upper * 0.1, yend = legend_upper - legend_upper * 0.1, size = 1) +
      geom_point(aes(x = 13.55, y = legend_upper + legend_upper * 0.03), shape = 16, size = 3, color = "#FF0100") +
      geom_point(aes(x = 13.55, y = legend_upper - legend_upper * 0.03), shape = 18, size = 4, color = "#18466E") +
      geom_point(aes(x = 13.55, y = legend_upper - legend_upper * 0.1), shape = 18, size = 4, color = "#63A15D") +
      geom_text( family = "Roboto", fontface = "bold", x = 15.2, y = legend_upper + legend_upper * 0.03, aes(label = "ONLY COVID")) +
      geom_text( family = "Roboto", fontface = "bold", x = 15, y = legend_upper - legend_upper * 0.03, aes(label = "ONLY NON COVID")) + 
      geom_text( family = "Roboto", fontface = "bold", x = 15, y = legend_upper - legend_upper * 0.1, aes(label = "MIXED"))
    
    
    
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
    
  } else {
    
    plot <- ggplot() +
      
      ggplot2::annotate("segment", x = 2018.5, xend = 2018.5, y = limit_lower - limit_lower*0.1, yend = limit_upper, color = "black", alpha = 0.5, size = 1, linetype = 2) +
      geom_point(data = data %>% filter(tender_covid == "ONLY COVID"), aes(x = as.numeric(DT_Y), y = !!variable), shape = 16, size = 3, color = "#FF0100") +
      geom_point(data = data %>% filter(tender_covid == "ONLY NON COVID"), aes(x = as.numeric(DT_Y), y = !!variable), shape = 18, size = 4, color = "#18466E") +
      geom_point(data = data %>% filter(tender_covid == "MIXED"), aes(x = as.numeric(DT_Y), y = !!variable), shape = 18, size = 4, color = "#63A15D") +
      geom_line(data = data %>% filter(tender_covid == "ONLY COVID"), aes(x = as.numeric(DT_Y), y = !!variable), size = 0.7, color = "#FF0100") +
      geom_line(data = data %>% filter(tender_covid == "ONLY NON COVID"), aes(x = as.numeric(DT_Y), y = !!variable), size = 0.7, color = "#18466E", linetype = 2) +
      geom_line(data = data %>% filter(tender_covid == "MIXED"), aes(x = as.numeric(DT_Y), y = !!variable), size = 0.7, color = "#63A15D", linetype = 2) +
      labs(title    = title,
           subtitle = subtitle,
           caption  = caption,
           x = NULL,
           y = NULL) +
      scale_x_continuous(breaks = seq(2016,2022),
                         labels = c(
                           "<b>2016</b>",
                           "<b>2017</b>",
                           "<b>2018</b>",
                           "<b>2019</b>",
                           "<b>2020</b>",
                           "<b>2021</b>",
                           "<b>2022</b>"
                         ),
                         limits = c(2015.5, 2024),
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
      ggplot2::annotate("segment", color = "#FF0100", x = 2021.5, xend = 2022, y = legend_upper + legend_upper * 0.03, yend = legend_upper + legend_upper * 0.03, size = 1) +
      ggplot2::annotate("segment", linetype = 2, color = "#18466E", x = 2021.5, xend = 2022, y = legend_upper - legend_upper * 0.03, yend = legend_upper - legend_upper * 0.03, size = 1) +
      ggplot2::annotate("segment", linetype = 2, color = "#63A15D", x = 2021.5, xend = 2022, y = legend_upper - legend_upper * 0.1, yend = legend_upper - legend_upper * 0.1, size = 1) +
      geom_point(aes(x = 2021.75, y = legend_upper + legend_upper * 0.03), shape = 16, size = 3, color = "#FF0100") +
      geom_point(aes(x = 2021.75, y = legend_upper - legend_upper * 0.03), shape = 18, size = 4, color = "#18466E") +
      geom_point(aes(x = 2021.75, y = legend_upper - legend_upper * 0.1), shape = 18, size = 4, color = "#63A15D") +
      geom_text( family = "Roboto", fontface = "bold", x = 2022.2, y = legend_upper + legend_upper * 0.03, aes(label = "ONLY COVID")) +
      geom_text( family = "Roboto", fontface = "bold", x = 2022.2, y = legend_upper - legend_upper * 0.03, aes(label = "ONLY NON COVID")) +
      geom_text( family = "Roboto", fontface = "bold", x = 2022.2, y = legend_upper - legend_upper * 0.1, aes(label = "MIXED"))
    
    if (percentage == TRUE) {
      
      plot <- plot +
        geom_text(
          data = data.frame(x = 2024, y = seq(limit_lower, limit_upper, by = interval_limits_y)),
          aes(x, y, label = paste0(y, "%")),
          hjust = 1, # Align to the right
          vjust = - 0.5, # Align to the bottom
          size = 5
        )
      
    } else {
      
      plot <- plot +
        geom_text(
          data = data.frame(x = 2024, y = seq(limit_lower, limit_upper, by = interval_limits_y)),
          aes(x, y, label = y),
          hjust = 1, # Align to the right
          vjust = - 0.5, # Align to the bottom
          size = 5
        )
      
    }
    
  }
  
  return(plot)
  
}

graph_trend_three_medical <- function(
    data, 
    variable,
    title, 
    subtitle, 
    caption,
    limit_lower,
    limit_upper, 
    interval_limits_y,
    legend_upper,
    percentage = FALSE
) {
  
  variable <- enquo(variable)
    
    plot <- ggplot() +
      
      ggplot2::annotate("segment", x = 8.5, xend = 8.5, y = limit_lower - limit_lower*0.1, yend = limit_upper, color = "black", alpha = 0.5, size = 1, linetype = 2) +
      geom_point(data = data %>% filter(tender_medical == "ONLY COVID" & DT_S != 9), aes(x = DT_S, y = !!variable), shape = 16, size = 3, color = "#FF0100") +
      geom_point(data = data %>% filter(tender_medical == "ONLY NON MEDICAL" & DT_S != 9), aes(x = DT_S, y = !!variable), shape = 18, size = 4, color = "#18466E") +
      geom_point(data = data %>% filter(tender_medical == "MIXED" & DT_S != 9), aes(x = DT_S, y = !!variable), shape = 18, size = 4, color = "#63A15D") +
      geom_line(data = data %>% filter(tender_medical == "ONLY COVID"), aes(x = DT_S, y = !!variable), size = 0.7, color = "#FF0100") +
      geom_line(data = data %>% filter(tender_medical == "ONLY NON MEDICAL"), aes(x = DT_S, y = !!variable), size = 0.7, color = "#18466E", linetype = 2)  +
      geom_line(data = data %>% filter(tender_medical == "MIXED"), aes(x = DT_S, y = !!variable), size = 0.7, color = "#63A15D", linetype = 2)  +
      labs(title    = title,
           subtitle = subtitle,
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
      ggplot2::annotate("segment", color = "#FF0100", x = 14, xend = 15, y = legend_upper + legend_upper * 0.03, yend = legend_upper + legend_upper * 0.03, size = 1) +
      ggplot2::annotate("segment", linetype = 2, color = "#18466E", x = 14, xend = 15, y = legend_upper - legend_upper * 0.03, yend = legend_upper - legend_upper * 0.03, size = 1) +
      ggplot2::annotate("segment", linetype = 2, color = "#63A15D", x = 14, xend = 15, y = legend_upper - legend_upper * 0.1, yend = legend_upper - legend_upper * 0.1, size = 1) +
      geom_point(aes(x = 13.55, y = legend_upper + legend_upper * 0.03), shape = 16, size = 3, color = "#FF0100") +
      geom_point(aes(x = 13.55, y = legend_upper - legend_upper * 0.03), shape = 18, size = 4, color = "#18466E") +
      geom_point(aes(x = 13.55, y = legend_upper - legend_upper * 0.1), shape = 18, size = 4, color = "#63A15D") +
      geom_text( family = "Roboto", fontface = "bold", x = 15.2, y = legend_upper + legend_upper * 0.03, aes(label = "ONLY MEDICAL")) +
      geom_text( family = "Roboto", fontface = "bold", x = 15, y = legend_upper - legend_upper * 0.03, aes(label = "ONLY NON MEDICAL")) +
    geom_text( family = "Roboto", fontface = "bold", x = 15, y = legend_upper - legend_upper * 0.1, aes(label = "MIXED"))
    
    
    
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




