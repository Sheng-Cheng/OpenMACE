import * as React from "react";
import { Marker } from "react-leaflet";
import * as L from "leaflet";
import { renderToString } from "react-dom/server";
import CommandControlIcon from "./icon";
import Tooltip from "../tooltip";
import * as Types from "../../../../../data-types/index";

const DEFAULT_WIDTH = 48;
const DEFAULT_HEIGHT = 48;

type Props = {
  data: Types.Environment.IconPayload;
};

const CommandControl = (props: Props) => {
  return (
    <Marker
      position={{lat: props.data.lat, lng: props.data.lng}}
      icon={L.divIcon({
        className: "command-control-icon",
        html: renderToString(
          <CommandControlIcon width={DEFAULT_WIDTH} height={DEFAULT_HEIGHT} />
        ),
        iconSize: L.point(DEFAULT_WIDTH, DEFAULT_HEIGHT, true),
        iconAnchor: L.point(DEFAULT_WIDTH / 2, DEFAULT_HEIGHT, true)
      })}
    >
      <Tooltip
        direction="right"
        offset={[16, -DEFAULT_HEIGHT / 2]}
        data={props.data}
        show
      />
    </Marker>
  );
};

export default CommandControl;