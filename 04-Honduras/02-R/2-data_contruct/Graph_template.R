
graph_trend <- function(
  data, 
  variable, 
  title, 
  subtitle, 
  caption,
  limit_lower,
  limit_upper, 
  interval_limits_y,
  legend_upper,
  label_treatment_legend = "Covid-19 items",
  label_control_legend = "Other items",
  percentage = FALSE) {
  
  variable <- enquo(variable)
  
  plot <- ggplot() +
    
    annotate("segment", x = 9, xend = 9, y = limit_lower - limit_lower*0.1, yend = limit_upper, color = "gray80", alpha = 0.5, size = 5) +
    geom_point(data = data %>% filter(COVID_19 == 1 & DT_Q != 9), aes(x = DT_Q, y = !!variable), shape = 16, size = 3, color = "#FF0100") +
    geom_point(data = data %>% filter(COVID_19 == 0 & DT_Q != 9), aes(x = DT_Q, y = !!variable), shape = 18, size = 4, color = "#18466E") +
    geom_line(data = data %>% filter(COVID_19 == 1), aes(x = DT_Q, y = !!variable), size = 0.7, color = "#FF0100") +
    geom_line(data = data %>% filter(COVID_19 == 0), aes(x = DT_Q, y = !!variable), size = 0.7, color = "#18466E", linetype = 2)  +
    labs(title    = title,
         subtitle = subtitle,
         caption  = caption,
         x = NULL,
         y = NULL) +
    scale_x_continuous(breaks = seq(1,16),
                       labels = c(
                         "<b>2018</b>",
                         "<em>Q2</em>",
                         "<em>Q3</em>",
                         "<em>Q4</em>",
                         "<b>2019</b>",
                         "<em>Q2</em>",
                         "<em>Q3</em>",
                         "<em>Q4</em>",
                         "<b>2020</b>",
                         "<em>Q2</em>",
                         "<em>Q3</em>",
                         "<em>Q4</em>",
                         "<b>2021</b>",
                         "<em>Q2</em>",
                         "<em>Q3</em>",
                         "<em>Q4</em>"
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
    annotate("rect", fill = "white", color = "white",
             xmin = 12.65, xmax = 16.35, ymin = legend_upper - 0.05 * legend_upper, ymax = legend_upper + legend_upper * 0.05
    ) + 
    annotate("segment", color = "#FF0100", x = 13, xend = 14, y = legend_upper + legend_upper * 0.03, yend = legend_upper + legend_upper * 0.03, size = 1) +
    annotate("segment", linetype = 2, color = "#18466E", x = 13, xend = 14, y = legend_upper - legend_upper * 0.03, yend = legend_upper - legend_upper * 0.03, size = 1) +
    geom_point(aes(x = 13.55, y = legend_upper + legend_upper * 0.03), shape = 16, size = 3, color = "#FF0100") +
    geom_point(aes(x = 13.55, y = legend_upper - legend_upper * 0.03), shape = 18, size = 4, color = "#18466E") +
    geom_text( family = "Roboto", fontface = "bold", x = 15.2, y = legend_upper + legend_upper * 0.03, aes(label = label_treatment_legend)) +
    geom_text( family = "Roboto", fontface = "bold", x = 15, y = legend_upper - legend_upper * 0.03, aes(label = label_control_legend))
  
  
  
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














